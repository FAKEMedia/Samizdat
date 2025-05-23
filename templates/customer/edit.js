const form = document.querySelector("#dataform");
form.addEventListener("submit", (event) => {
  event.preventDefault();
});

async function sendData(method, customerid = 0) {
  if (customerid > 0) {
    form.action = '<%== sprintf("%s%s/", config->{managerurl}, "customers") %>' + customerid;
  }
  const url = form.action || "";
  const formData = new FormData(form);
  const request = {
    method: method,
    headers: {Accept: 'application/json'}
  };
  if (method != 'GET') {
    request.body = formData;
  }
  try {
    const response = await fetch(url, request);
    if (response.error) {
      alert(error);
    } else {
      populateForm(await response.json(), method);
    }
  } catch (e) {
    console.error(e);
  }
}

// https://deano.me/javascript-change-address-bar-url-when-loading-content-with-ajax/
window.onpopstate = function(event) {
//  alert("location: " + document.location + ", state: " + JSON.stringify(event.state));
  if (event.state != undefined) {
//    loadPage(document.location.toString(),1);
  }
};
var stateObj = { foo: 1000 + Math.random()*1001 };
async function getId(what, customerid = 0) {
  let url = '<%== sprintf("%s%s/", config->{managerurl}, "customers") %>';
  customerid = parseInt(customerid);
  if (customerid > 1000) {
    url += customerid;
    url += '/';
  }
  url += what;
  const request = {
    method: 'GET',
    headers: {Accept: 'application/json'}
  };
  try {
    const response = await fetch(url, request);
    if (response.error) {
      alert(error);
    } else {
      populateForm(await response.json(), 'GET');
      return true;
    }
  } catch (e) {
    console.error(e);
  }
}

function updateCustomer(){
  sendData('PUT');
}

function createCustomer() {
//  sendData('POST');
  form.submit();
}

function getCustomer(customerid = 0) {
  sendData('GET', customerid);
}


function populateForm(formdata, method) {
  let customer = formdata.customer;
  let domains = formdata.domains;
  let dnsdomains = formdata.dnsdomains;
  let invoices = formdata.invoices;
  let invoiceitems = formdata.invoiceitems;
  let databases = formdata.databases;
  let sites = formdata.sites;
  let maildomains = formdata.maildomains;
  let subscriptions = formdata.subscriptions;
  let userlogins = formdata.userlogins;

  // Customer data, including default values for new customer
  for (const field of [<%== join ", ", map "\"$_\"" => @{$fields} %>]) {
    if (Object.hasOwn(customer, field)) {
      document.querySelector('#' + field).value = customer[field];
    }
  }
  for (const checkfield of [<%== join ", ", map "\"$_\"" => @{$checkfields} %>]) {
    if (Object.hasOwn(customer, checkfield)) {
      document.querySelector('#' + checkfield).checked = (customer[checkfield] > 0) ? true : false;
    } else {
      document.querySelector('#' + checkfield).checked = false;
    }
  }

  // Reset generated content
  document.querySelectorAll('.reset').forEach((el) => {
    el.href = '';
    el.classList.add("d-none");
  });
  document.querySelectorAll('.blank').forEach((el) => {
    el.innerHTML = '';
    if (el.tagName == 'SPAN') {
      el.classList.add("d-none");
    }
  });

  document.querySelector('#minid').setAttribute('onclick', `return getId('first', 1000);`);
  document.querySelector('#maxid').setAttribute('onclick', `return getId('newest', 1000);`);
  if (0 == customer.customerid) {
    thisurl = `<%== sprintf("%s%s/new", config->{managerurl}, "customers") %>`;
    document.querySelector('#dataform').action = '<%== sprintf("%s%s", config->{managerurl}, "customers") %>';
    document.querySelector('#submitbutton').innerHTML = `<%== __('Create customer') %>`;
    document.querySelector('#submitbutton').setAttribute('onclick', 'createCustomer();');
    document.querySelector('#previd').setAttribute('onclick', `return getId('first', 1000);`);
    document.querySelector('#nextid').setAttribute('onclick', `return getId('newest', 1000);`);
    return;
  }

  document.querySelector('#submitbutton').innerHTML = `<%== __('Update customer') %>`;
  document.querySelector('#submitbutton').setAttribute('onclick', 'updateCustomer();')
  thisurl = `<%== sprintf("%s%s/", config->{managerurl}, "customers") %>${ customer.customerid }`
  history.pushState(stateObj, "ajax page loaded...", thisurl);
  document.querySelector('#dataform').action = thisurl;
  document.querySelector('#headline').innerHTML = `<%==__('Customer') %> #${customer.customerid}`;
  document.querySelector('#previd').setAttribute('onclick', `return getId('prev', ${customer.customerid});`);
  document.querySelector('#nextid').setAttribute('onclick', `return getId('next', ${customer.customerid});`);

  if (Object.hasOwn(customer, 'vatno') && ('' != customer.vatno)) {
    document.querySelector('#vatlookup').href = `<%== sprintf('%s%s/', config->{managerurl}, 'vatno') %>${customer.vatno}`;
    document.querySelector('#vatlookup').classList.remove("d-none");
  }
  if (Object.hasOwn(customer, 'contactemail') && ('' != customer.contactemail)) {
    document.querySelector('#mailto').href = 'mailto:' + customer.contactemail;
    document.querySelector('#mailto').classList.remove("d-none");
  }
  if (Object.hasOwn(customer, 'phone1') && ('' != customer.phone1)) {
    let tel1 = customer.phone1.replace(/[^+0-9]+/g, '');
    if ('' != tel1) {
      document.querySelector('#tel1').href = 'tel:' + tel1;
      document.querySelector('#tel1').classList.remove("d-none");
    }
  }
  if (Object.hasOwn(customer, 'phone2') && ('' != customer.phone2)) {
    let tel2 = customer.phone2.replace(/[^+0-9]+/g, '');
    if ('' != tel2) {
      document.querySelector('#tel2').href = 'tel:' + tel2;
      document.querySelector('#tel2').classList.remove("d-none");
      document.querySelector('#sms').href = 'sms:' + tel2;
      document.querySelector('#sms').classList.remove("d-none");
    }
  }
  let eucountries = /(<%== join '|',  @{$eucountries} %>)/i;
  if (Object.hasOwn(customer, 'orgno') && ('' != customer.orgno)) {
    if ('SE' == customer.country) {
      if (parseInt(customer.orgno.substring(2, 4)) < 20) {
        document.querySelector('#upplysning').href = `https://upplysning.se/person/?sl=detail&b=${customer.orgno}`;
        document.querySelector('#upplysning').classList.remove("d-none");
      }
      document.querySelector('#allabolag').href = `https://www.allabolag.se/?what=${customer.orgno}`;
      document.querySelector('#allabolag').classList.remove("d-none");
    } else if ('NO' == customer.country) {
      document.querySelector('#brreg').href = `https://w2.brreg.no/enhet/sok/valg.jsp?inputparam=${customer.orgno}`;
      document.querySelector('#brreg').classList.remove("d-none");
    } else if (eucountries.test(customer.country)) {
      document.querySelector('#ejustice').href = `https://e-justice.europa.eu/content_find_a_company-489-en.do?companyRegNumber=${customer.orgno}&amp;searchCountries=${customer.country}`;
      document.querySelector('#ejustice').classList.remove("d-none");
    }
  }

  // Userlogins
  for (const userlogin of userlogins) {
    document.querySelector('#userlogin').innerHTML = `${userlogin.userlogin}`;
//    document.querySelector('#userlogin').href = `/phpmyadmin/tbl_change.php?db=system2&table=snapusers&where_clause=%60snapusers%60.%60userlogin%60%3D%27${userlogin..userlogin}%27&clause_is_unique=1&sql_query=SELECT%20%2A%20FROM%20%60systems%60.%60snapusers%60%20AS%20%60snapusers%60&goto=sql.php&default_action=update`;
    document.querySelector('#impersonate').href = `/login/?action=impersonate&amp;impersonate=${userlogin.userlogin}`;
  }

  // Invoices
  let snippet = '';
  let due = 0;
  let notdue = 0;
  let paid = 0;
  invoices = invoices.sortBy('-invoicedate', '-invoiceid');
  for (const invoice of invoices) {
    let rowclass = ['text-end'];
    if (invoice.due) {
      due++;
      rowclass.push('text-white');
      rowclass.push('bg-danger');
    } else if ('fakturerad' === invoice.state) {
      notdue++;
      rowclass.push('text-dark');
      rowclass.push('bg-warning');
    } else if ('bokford' === invoice.state) {
      paid++;
      rowclass.push('text-white');
      rowclass.push('bg-success');
    }
    snippet += `
                <tr data-invoiceid="${invoice.invoiceid}">
                  <td><a href="<%== config->{siteurl} %>/invoice/${invoice.uuid}.pdf"><%== icon 'file-pdf' %></a></td>
                  <td><a class="w-auto" href="<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/invoices/${invoice.invoiceid}">${invoice.fakturanummer}</a></td>
                  <td>${invoice.invoicedate.substring(10, 0)}</td>
                  <td class="text-end">${invoice.costsum}</td>
                  <td class="${rowclass.join(' ')}">${invoice.state}</td>
                </tr>`;
  }
  document.querySelector('#invoices tbody').innerHTML = snippet;
  document.querySelectorAll('.currencynote').forEach((currencynote) => {
    currencynote.innerHTML = `${'<%== __x("Invoice currency is {currency}.", currency => "customercurrency") %>'.replace('customercurrency', customer.currency.toUpperCase())}`;
  });
  if (due > 0) {
    document.querySelector('#due').innerHTML = due;
    document.querySelector('#due').classList.remove("d-none");
  }
  if (notdue > 0) {
    document.querySelector('#notdue').innerHTML = notdue;
    document.querySelector('#notdue').classList.remove("d-none");
  }
  if (paid > 0) {
    document.querySelector('#paid').innerHTML = paid;
    document.querySelector('#paid').classList.remove("d-none");
  }

  // Invoice items in open invoice
  snippet = '';
  let amount = 0;
  let nrinvoiceitems = 0;
  for (let invoiceitemid in invoiceitems) {
    if (invoiceitems.hasOwnProperty(invoiceitemid)) {
      let invoiceitem = invoiceitems[invoiceitemid];
      amount += invoiceitem.price * invoiceitem.number * (1 + customer.vat / 100);
      let checked = (invoiceitem.include > 0) ? 'checked="true" ' : '';
      snippet += `
                <tr class="invoiceitem" data-invoiceitemid="${invoiceitemid}">
                  <td class="w-auto">${invoiceitem.invoiceitemtext}</td>
                  <td class="text-end">${(1 + customer.vat / 100) * invoiceitem.number * invoiceitem.price}</td>
                </tr>`;
    }
    nrinvoiceitems++;
  }
  document.querySelector('#invoiceitems tbody').innerHTML = snippet;
  document.querySelector('#amount').innerHTML = amount;
  if (nrinvoiceitems > 0) {
    document.querySelector('#nrinvoiceitems').innerHTML = nrinvoiceitems;
    document.querySelector('#nrinvoiceitems').classList.remove("d-none");
  }
  document.querySelectorAll('.openinvoicelink').forEach((openinvoicelink) => {
    openinvoicelink.href = `<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/invoices/open`;
  });

  // Domains
  snippet = '';
  let duedomains = 0;
  let nrdomains = 0;
  domains = domains.sortBy('domainname');
  for (const domain of domains) {
    let rowclass = [domain.registrantid, 'text-end'];
    if (domain.due) {
      duedomains++;
      rowclass.push('text-white bg-danger');
    }
    nrdomains++;
    snippet += `
                <tr data-domainid="${domain.domainid}">
                  <td><a href="<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/${domains.domainid}">${domain.domainname}</a></td>
                  <td class="${rowclass.join(' ')}">${domain.curexpiry.substring(10, 0)}</td>
                </tr>`;
  }
  document.querySelector('#domains tbody').innerHTML = snippet;
  if (duedomains > 0) {
    document.querySelector('#duedomains').innerHTML = duedomains;
    document.querySelector('#duedomains').classList.remove("d-none");
  }
  if (nrdomains > 0) {
    document.querySelector('#nrdomains').innerHTML = nrdomains;
    document.querySelector('#nrdomains').classList.remove("d-none");
  }
  document.querySelector('#domainlistlink').href = `<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/domains`;

  // DNS domains
  snippet = '';
  let nrdnsdomains = 0;
  dnsdomains = dnsdomains.sortBy('domainname');
  for (const dnsdomain of dnsdomains) {
    nrdnsdomains++;
    snippet += `
                <tr data-zoneid="${dnsdomain.domainid}"><td><a class="d-block" href="<%== config->{managerurl} %>dnsadmin/${dnsdomain.domainname}./records/">${dnsdomain.domainname}</a></td></tr>`;
  }
  document.querySelector('#dnsdomains tbody').innerHTML = snippet;
  if (nrdnsdomains > 0) {
    document.querySelector('#nrdnsdomains').innerHTML = nrdnsdomains;
    document.querySelector('#nrdnsdomains').classList.remove("d-none");
  }

  // Websites
  snippet = '';
  let nrsites = 0;
  let webusage = 0;
  let datausage = 0;
  sites = sites.sortBy('domainName');
  for (const site of sites) {
    nrsites++;
    webusage += site.webusage;
    datausage += site.webusage;
    snippet += `
                <tr data-domainPK="${site.domainPK}">
                  <td><a class="d-block" href="<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/sites/${site.domainName}">${site.domainName}</a></td>
                  <td class="text-end">${shortbytes(site.webusage)}</td>
                </tr>`;
  }
  document.querySelector('#sites tbody').innerHTML = snippet;
  if (nrsites > 0) {
    document.querySelector('#nrsites').innerHTML = nrsites;
    document.querySelector('#nrsites').classList.remove("d-none");
  }

  // Mail domains
  snippet = '';
  let nrmaildomains = 0;
  let mailusage = 0;
  maildomains = maildomains.sortBy('domainname');
  for (const maildomain of maildomains) {
    nrmaildomains++;
    mailusage += maildomain.mailusage;
    datausage += maildomain.mailusage;
    snippet += `
                <tr data-domainname="${maildomain.domainname}">
                  <td><a class="d-block" href="<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/maildomains/${maildomain.domainname}">${maildomain.domainname}</a></td>
                  <td class="text-end">${shortbytes(maildomain.mailusage)}</td>
                </tr>`;
  }
  document.querySelector('#maildomains tbody').innerHTML = snippet;
  if (nrmaildomains > 0) {
    document.querySelector('#nrmaildomains').innerHTML = nrmaildomains;
    document.querySelector('#nrmaildomains').classList.remove("d-none");
  }

  // Datahases
  snippet = '';
  let nrdatabases = 0;
  let dbusage = 0;
  databases = databases.sortBy('databasename');
  for (const database of databases) {
    nrdatabases++;
    dbusage += database.db_usage;
    datausage += database.db_usage;
    snippet += `
                <tr data-databasename="${database.databasename}">
                  <td><a href="<%== sprintf('/phpmyadmin/index.php?route=/database/structure&server=1&db=', config->{siteurl}) %>${database.databasename}"><%== icon 'link' %></a></td>
                  <td><a class="d-block" href="<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/databases/${database.databasename}">${database.databasename}</a></td>
                  <td>${database.username}</td>
                  <td class="text-end">${shortbytes(database.db_usage)}</td>
                </tr>`;
  }
  document.querySelector('#databases tbody').innerHTML = snippet;
  if (nrdatabases > 0) {
    document.querySelector('#nrdatabases').innerHTML = nrdatabases;
    document.querySelector('#nrdatabases').classList.remove("d-none");
  }

  // Subscriptions
  snippet = '';
  for (const subscription of subscriptions) {
    snippet += `
            <li class="list-group-item fw-bold subscription">
              ${subscription.productname}
              <div class="position-absolute top-50 me-2 end-0 translate-middle-y text-break">
                <a href="<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>/${customer.customerid}/products/${subscription.productid}/remove"><%== icon 'trash' %></a>
              </div>
            </li>`;
  }

  document.querySelectorAll('.subscription').forEach((subscription) => {
    subscription.remove();
  });
  document.querySelector('#subscriptions').innerHTML = snippet + document.querySelector('#subscriptions').innerHTML;
  document.querySelector('#addproductlink').href = `<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/products/subscribe`;
  document.querySelector('#adddomainlink').href = `<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/domains/new`;
  document.querySelector('#addsitelink').href = `<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/sites/new`;
  document.querySelector('#adddatabaselink').href = `<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/databases/new`;
  document.querySelector('#adddnsdomainlink').href = `<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/dnsdomains/new`;
  document.querySelector('#addmaildomainlink').href = `<%== sprintf('%s%s/', config->{managerurl}, 'customers') %>${customer.customerid}/maildomains/new`;

  if (datausage > 0) {
    document.querySelector('#datausage').innerHTML = '<%== __x("Data usage: {usage}", usage => "datausage") %>'
      .replace('datausage', shortbytes(datausage));
    document.querySelector('#datausage').classList.remove("d-none");

  }
  if (customer.updater != '') {
    document.querySelector('#updater').innerHTML = "<%== __x('Updated {updated} by {updater}', updated => 'updated', updater => 'updater') %>"
      .replace('updated', customer.updated.substring(0, 10))
      .replace('updater', customer.updater);
    document.querySelector('#updater').classList.remove("d-none");
  }
  if (customer.creator != '') {
    document.querySelector('#creator').innerHTML = "<%== __x('Created {created} by {creator}', created => 'created', creator => 'creator') %>"
      .replace('created', customer.created.substring(0, 10))
      .replace('creator', customer.creator);
    document.querySelector('#creator').classList.remove("d-none");
  }


  if ('PUT' == method) {
    document.querySelector('#toast-messages').innerHTML = `
<%== indent $toast, 1 %>`;

    window.setTimeout(dropToast, 2000);
  }
}

function dropToast() {
  document.querySelector('#toast-messages').innerHTML = '';
}

getCustomer();