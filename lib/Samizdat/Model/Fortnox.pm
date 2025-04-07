package Samizdat::Model::Fortnox;

use Mojo::Base -base, -signatures;
use Mojo::Promise;
use Mojo::JSON qw(decode_json encode_json from_json);
use Mojo::Collection qw(c);
use Mojo::UserAgent;
use Mojo::File qw(path);
use Hash::Merge;
use Data::Dumper;

has 'config';
has 'cache' => sub ($self) {
  state $cache = Cache($self->config->{cachefile});
  return $cache;
};
has 'merger' => sub {
  state $merger = Hash::Merge->new();
  return $merger;
};
has 'application' => 'myapplication';
has 'ua' => sub ($self) {
  state $ua = Mojo::UserAgent->new->max_redirects(0)->connect_timeout(3)->request_timeout(2);
  return $ua;
};


sub Cache ($cachefile, $cache = undef) {
  if ($cache) {
    return path($cachefile)->spew(encode_json($cache));
  } elsif (-f $cachefile) {
    my $json = path($cachefile)->slurp;
    if ($json) {
      return decode_json($json);
    }
  }
  return {
    'state'   => 'login',
    'access'  => '',
    'refresh' => '',
    'code'    => ''
  };
}

sub saveCache ($self) {
  return Cache($self->config->{cachefile}, $self->cache);
}

sub updateCache ($self, $resource = undef) {
  my $resources = [];
  if ($resource) {
    push @{ $resources }, $resource;
  } else {
    push @{ $resources }, sort {$a cmp $b} keys %{ $self->config->{apps}->{$self->application}->{resources} };
  }
  for my $resource (@{ $resources }) {
    my $resourceconfig = $self->config->{apps}->{$self->application}->{resources}->{$resource};
    if (exists($resourceconfig->{cache}) && int $resourceconfig->{cache}) {
      my $list = [];
      my $page = 1;
      my $fetch = {};
      my $object = exists($resourceconfig->{object}) ? $resourceconfig->{object} : $resource;
      do {
        $fetch = $self->callAPI($resource, 'get', 0, {qp => {page => $page}});
        if (exists($fetch->{$object})) {
          push(@{$list}, @{$fetch->{$object}});
        }
        $page++;
      } until (!exists($fetch->{'MetaInformation'}) or $fetch->{'MetaInformation'}->{'@CurrentPage'} >= $fetch->{'MetaInformation'}->{'@TotalPages'});
      $self->cache->{$self->application}->{$resource} = $list;
      $self->saveCache;
    }
  }
  $self->saveCache;
  return ($resource) ? $self->cache->{$self->application}->{$resource} : $self->cache;
}

sub removeCache ($self) {
  unlink $self->config->{cachefile} if (-e $self->config->{cachefile});
  state $cache = undef;
}

sub getLogin($self) {
  $self->cache->{state} = 'login';
  my $response = $self->ua->get($self->config->{oauth2}->{url} . '/auth' => {Accept => '*/*'} => form => {
    client_id     => $self->config->{apps}->{$self->application}->{clientid},
    scope         => $self->config->{apps}->{$self->application}->{scope},
    access_type   => $self->config->{oauth2}->{access_type},
    account_type  => $self->config->{oauth2}->{account_type},
    state         => $self->cache->{state},
    response_type => 'code',
  })->result;
  if ($response->headers->header('Location')) {
    $self->cache->{state} = 'code';
    $self->saveCache;
    #        return sprintf($response->headers->header('Location'));
    my $redirect = sprintf("https://apps.fortnox.se%s\n", $response->headers->header('Location'));
    return $redirect;
  }
  return 0;
}

sub getToken ($self, $refresh = 0) {
  my $url = Mojo::URL->new($self->config->{oauth2}->{url} . '/token')->userinfo(sprintf('%s:%s',
    $self->config->{apps}->{$self->application}->{clientid},
    $self->config->{apps}->{$self->application}->{secret}
  ));
  my $response;
  if ($refresh) {
    $response = $self->ua->post($url => { Accept => '*/*' } => form => {
      grant_type    => 'refresh_token',
      refresh_token => $self->cache->{refresh},
    })->result;
  } else {
    $response = $self->ua->post($url => { Accept => '*/*' } => form => {
      grant_type   => 'authorization_code',
      code         => $self->cache->{code},
      redirect_uri => $self->config->{oauth2}->{redirect_uri},
    })->result;
  }
#  $response->save_to($self->config->{cachefile});
  if ($response->json('/error')) {
    return 0;
  } else {
    $self->cache->{code} = '';
    $self->cache->{refresh} = $response->json('/refresh_token');
    $self->cache->{access} = $response->json('/access_token');
    $self->cache->{state} = 'api';
    $self->saveCache;
    return 1;
  }
}


sub callAPI ($self, $resource, $method, $id = 0, $options = {}, $action = '') {
  if (!exists($self->cache->{access})) {
    return $self->getLogin();
  }
  $resource = lc $resource;
  my $url = $self->config->{apiurl};
  if ('put' eq $method) {
    return 0 if (!$id);
    $url = ('' eq $action) ? sprintf("%s%s/%d", $url, $resource, $id) : sprintf("%s%s/%d/%s", $url, $resource, $id, $action);
  } elsif ('delete' eq $method) {
    return 0 if (!$id);
    $url = sprintf("%s%s/%d", $url, $resource, $id);
  } elsif ('post' eq $method) {
    $url = sprintf("%s%s", $url, $resource);
  } elsif ('get' eq $method) {
    if ($id) {
      if ('' eq $action) {
        $url = sprintf("%s%s/%s", $url, $resource, $id);
      } else {
        $url = sprintf("%s%s/%d/%s", $url, $resource, $id, $action);
      }
    } else {
      $url = sprintf("%s%s", $url, $resource);
    }
  }
  my $done = 0;
  my $qp = {};

  if (!$id) {
    $qp = $options->{qp} if (exists($options->{qp}));
  }
  while (!$done) {
    $qp = $self->merger->merge($self->config->{apps}->{$self->application}->{resources}->{$resource}->{qp}, $qp);
    $qp = $self->merger->merge($options->{qp}, $qp);
    for my $p (qw/sortby sortorder filter limit offset page/) {
      #          delete $qp->{$p} if (exists($qp->{$p}) and ($qp->{$p} eq ''));
    }
    #        say $resource . Dumper $qp;
    my $tx;
    #        say $url;
    if ('get' eq $method) {
      $tx = $self->ua->build_tx('GET' => $url => {Accept => '*/*'} => form => $qp);
    } else {
      if ($resource =~ /^(Archive|Inbox)$/) {
        if (exists($options->{qp}->{file})) {
          if (my $content = path->new($options->{qp}->{file})->slurp) {
            delete $options->{qp}->{file};
            $options->{qp}->{File} = {
              $content
            };
          }
        }
      }
      $tx = $self->ua->build_tx(uc($method) => $url => {Accept => '*/*'} => json => $options);
#      say Dumper $tx;
      $tx->req->headers->content_type('application/json');
    }
    $tx->req->headers->add(Authorization => sprintf('Bearer %s', $self->cache->{access}));
    $tx = $self->ua->start($tx);
    #        say $tx->req->to_string;

    if (403 == $tx->result->code) {
      say sprintf('%s %s', $tx->result->code, Dumper $tx->result->body);
      $self->cache->{access} = '';
      $self->cache->{state} = '';
      $self->cache->{refresh} = '';
      $self->saveCache;
      $done = 1;
      return {};
    } elsif (404 == $tx->result->code) {
      $done = 1;
      return 404;
    } elsif (400 == $tx->result->code) {
      say sprintf('%s %s %s', $url, $tx->result->code, Dumper $tx->result->body);
      $done = 1;
      return 400;
    } elsif ($tx->result->code =~ /^4/) {
      #          say sprintf('%s %s', $tx->result->code, Dumper $tx->result->body);

      #          if (2000311 == $result->{'ErrorInformation'}->{Code}) {}

      $self->cache->{access} = '';
      $self->cache->{state} = 'code';
      $self->saveCache;
      $self->getToken(1);
    } elsif (200 == $tx->result->code || 201 == $tx->result->code) {
      #          say Dumper $tx->result->body;
      my $result = decode_json($tx->result->body);
      #          say Dumper $result;
      return $result;
    }
    sleep 2;
  }
}


sub postInbox ($self, $file, $folderid = 'inbox_kf') {
  my $url = sprintf("%s%s?folderid=%s", $self->config->{apiurl}, 'inbox', $folderid);
  my $headers = {
    'Content-Type'  => 'multipart/form-data',
    'Authorization' => sprintf('Bearer %s', $self->cache->{access})
  };
  my $tx;
  if (1) {
    my $tx = $self->ua->build_tx('POST' => $url => $headers => form => {
      file => { file => $file }
    });
#    say Dumper $tx;
    $tx = $self->ua->start($tx);
    say sprintf('%s %s %s', $url, $tx->result->code, Dumper $tx->result->body);

    if (201 == $tx->result->code) {
      return decode_json($tx->result->body);
    }

    #  say Dumper $tx;
#    return $tx->result;
  }
}


sub attachment ($self, $method, $fileid, $entityid, $entitype = 'F') {
  my $url = $self->config->{attachmentsurl};
  my $tx;
  # say $url;
  if ('get' eq $method) {
    $tx = $self->ua->build_tx('GET' => $url => {Accept => '*/*'} => form => {
      entityid      => $entityid,
      entitytype    => $entitype,
    });
  } else {
    $tx = $self->ua->build_tx(uc($method) => $url => {Accept => '*/*'} => json => [{
      fileId        => $fileid,
      entityId      => $entityid,
      entityType    => $entitype,
      includeOnSend => 'true',
    }]);
    $tx->req->headers->content_type('application/json');
  }
  $tx->req->headers->add(Authorization => sprintf('Bearer %s', $self->cache->{access}));
  $tx = $self->ua->start($tx);
  say sprintf('%s %s %s', $url, $tx->result->code, Dumper $tx->result->body);

  if (200 == $tx->result->code) {
    say Dumper $tx->result->body;
    my $result = decode_json($tx->result->body);
    #          say Dumper $result;
    return $result;
  }
}

sub financialYears ($self) {
  $self->updateCache('FinancialYears') if (!exists($self->cache->{$self->application}->{FinancialYears}));
  return Mojo::Collection->new(@{ $self->cache->{$self->application}->{FinancialYears} });
}

sub accounts ($self) {
  $self->updateCache('Accounts') if (!exists($self->cache->{$self->application}->{Accounts}));
  return Mojo::Collection->new(@{ $self->cache->{$self->application}->{Accounts} });
}

sub postInvoice ($self, $payload) {
  my $result = $self->callAPI('Invoices', 'post', 0, $payload);
}

sub externalInvoice ($self, $DocumentNumber = 0) {
  if ($DocumentNumber) {
    my $result = $self->callAPI('Invoices', 'put', 0, {}, 'externalprint');
    say Dumper $result;
  }
}

sub creditInvoice ($self, $DocumentNumber = 0) {
  if ($DocumentNumber) {
    my $result = $self->callAPI('Invoices', 'put', 0, {}, 'credit');
    say Dumper $result;
  }
}

sub getInvoice ($self, $DocumentNumber = 0, $options = {'qp' => {'limit' => 500, page => 1}}) {
  my $list = $self->callAPI('Invoices', 'get', $DocumentNumber, $options);
}

sub putInvoice ($self, $DocumentNumber = 0) {
  return 0 if (!$DocumentNumber);
  my $result = $self->callAPI('Invoices', 'put', $DocumentNumber);
}

sub getCustomer ($self, $CustomerNumber = 0, $options = {'qp' => {'limit' => 500, page => 1}}) {
  my $result = $self->callAPI('Customers', 'get', $CustomerNumber, $options);
}

sub putCustomer ($self, $CustomerNumber, $data = {}) {
  my $result = $self->callAPI('Customers', 'put', $CustomerNumber, $data);
}

sub postCustomer ($self, $data =  {}) {
  my $result = $self->callAPI('Customers', 'post', 0, $data);
}

sub deleteCustomer ($self, $CustomerNumber) {
  my $result = $self->callAPI('Customers', 'delete', $CustomerNumber);
}

sub putCurrency ($self, $Currency, $data = {}) {
  my $result = $self->callAPI('Currencies', 'put', $Currency, $data);
}

sub getCurrency ($self, $Currency = 0, $options = {'qp' => {'limit' => 500, page => 1}}) {
  my $result = $self->callAPI('Currencies', 'get', $Currency, $options);
}

sub postCurrency ($self, $data = {}) {
  my $result = $self->callAPI('Currencies', 'post', 0, $data);
}

sub getAccount ($self, $Number = 0, $options = {'qp' => {'limit' => 500, page => 1}}) {
  my $result = $self->callAPI('Accounts', 'get', $Number, $options);
}

sub getArticle ($self, $ArticleNumber = 0, $options = {'qp' => {'limit' => 500, page => 1}}) {
  if ($ArticleNumber) {
    return $self->callAPI('Articles', 'get', $ArticleNumber, $options);
  } else {
    return { Articles => $self->updateCache('Articles') };
  }
}

sub postArticle ($self, $article) {
  my $payload = {
    Article => {
      'ArticleNumber' => $article->{number},
      'Description'   => $article->{description},
      'Type'          => 'SERVICE',
#      'SalesAccount'  => $article->{account},
#      'EUVATAccount'  => $article->{euvataccount},
#      'ExportAccount'  => $article->{exportaccount},
    }
  };
  my $result = $self->callAPI('Articles', 'post', 0, $payload);
}


sub getArchive ($self, $id = 0, $options = {'qp' => {'limit' => 500, page => 1}}) {
  if ($id) {
    # This is possibly a file
    return $self->callAPI('Archive', 'get', $id, $options);
  } else {
    #This is a folder with folders and files
    my $result = $self->callAPI('Archive', 'get', 0, $options);
    say Dumper $result;
  }
}

1;