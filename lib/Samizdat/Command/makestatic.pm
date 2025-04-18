package Samizdat::Command::makestatic;

use Mojo::Base 'Mojolicious::Command', -signatures;
use Mojo::UserAgent;
use Time::HiRes qw(usleep);
use Mojo::Util qw(decode encode);
use Data::Dumper;

has description => 'Apply templates to markdown files and dump resulting files in the public dir';
has usage => sub ($self) { $self->extract_usage };

my $ua = Mojo::UserAgent->new;

sub run ($self, @args) {
  my $language = $ENV{'LANG'};
  $language = (split(':', $language))[0];
  $language = (split('_', $language))[0];

  $ua->cookie_jar->add(
    Mojo::Cookie::Response->new(
      name   => 'language',
      value  => $language,
      domain => $self->app->config->{cookiedomain},
      path   => '/'
    )
  );

  my $uris = $self->app->web->geturis;
  my $again = 1;
  my $siteurl = $self->app->config->{siteurl};
  $siteurl =~ s/\/$//;
  my $server = ${ $self->app->config->{hypnotoad}->{listen} }[0];
  $server =~ s/\?.*//;
  while ($again) {
    $again = 0;
    for my $uri (sort {$a cmp $b} keys %$uris) {
      next if ($uri =~ /^#/);
      next if ($uri =~ /\.(jpg|jpeg|png|ico|pdf|gif|svg|mp4|webp)/);
      next if ($uri =~ /^\/\//);
      next if ($uri =~ /^mailto/);
      next if ($uri =~ /^javascript/);
      next if ($uri =~ /^country/);

      my $language = '';
      if ($uri =~ s/_([^_\.]+)\.md/.md/) {
        $language = $1;
      }
      $uri =~ s/README\.md//;
      $uri =~ s/^\///g;
      $uri =~ s/^\.\///g;
      if (!$uris->{$uri}) {
        my $res = $ua->get(sprintf('%s/%s', $server, $uri))->result;
        say sprintf('%s/%s %3d', $server, $uri, $res->code);
        $uris->{$uri} = 1;
        $res->dom('img, a')->each(sub($dom, $i) {
          my $link = '';
          if ('a' eq $dom->tag) {
            $link = $dom->attr('href') // '';
          } elsif ('img' eq $dom->tag) {
            $link = $dom->attr('src') // '';
          }
          if ('' ne $link) {
            $link =~ s/$siteurl//;
            if ($link !~ /http/) {
              if (!exists($uris->{$link})) {
                $uris->{$link} = 0;
                $again = 1;
              }
            }
          }
        });
      }
    }
  };
}

=head1 SYNOPSIS

  Usage: samizdat makestatic


=cut

1;