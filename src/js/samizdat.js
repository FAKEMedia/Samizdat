import '../scss/samizdat.scss';
import { Modal, Collapse, Dropdown, Offcanvas, Toast, Tooltip } from 'bootstrap';
window.bootstrap = { Modal, Collapse, Dropdown, Offcanvas, Toast, Tooltip };

import './user.js';
import './sortby.js';
import './tablesorter.js';
// import './sendform.js';
import './local.js';
import './serviceworker.js';
import './language.js';
import 'sprintf-js';
import './shortbytes.js';

let toastElList = document.querySelectorAll('.toast');
let toastList = [...toastElList].map(toastEl => new Toast(toastEl));