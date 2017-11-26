// ==UserScript==
// @name Tumblr Left-and-Right!
// @namespace https://github.com/koyae
// @description Adds hotkeys to *.tumblr.com blogs to allow navigating forward and backward by pages.
// @author koyae | https://github.com/koyae
// @version 0.01
// @encoding utf-8
// @include http://*.tumblr.com/*
// @include https://*.tumblr.com/*
// @exclude https://tumblr.com/*
// @exclude https://www.tumblr.com/*
// @exclude http://*.tumblr.com/post/*
// @exclude http://*.tumblr.com/image/*
// @exclude https://*.tumblr.com/post/*
// @exclude https://*.tumblr.com/image/*
// @grant unsafeWindow
// @run-at document-start
// @connect *
// ==/UserScript==
/*jshint evil:true newcap:false*/
/*global unsafeWindow, GM_addStyle, GM_getValue, GM_setValue, GM_xmlhttpRequest, GM_registerMenuCommand, GM_deleteValue, GM_listValues, GM_getResourceText, GM_getResourceURL, GM_log, GM_openInTab, GM_setClipboard, GM_info, GM_getMetadata, $, document, console, location, setInterval, setTimeout, clearInterval*/

// console.log("LOADED");

var path = location.pathname;
var domain = location.host;
var pageCap = path.match(/^\/page\/(\d+)/);
var page = (pageCap===null)? 1 : Number(pageCap[1]);

set_up();

function handle_keyup(event) {

  // if additional keys such as alt, ctrl, or shift were pressed, don't nav:
  if (event.shiftKey || event.ctrlKey || event.altKey || event.metaKey) return;

  if (event.keyCode === KeyEvent.DOM_VK_LEFT) {
    // if already at the most-recent page of content, do nothing:
    if (page===1) return;
    location.href = path.replace(/\d+/, page - 1);
  } else if (event.keyCode === KeyEvent.DOM_VK_RIGHT) {
     location.href = (pageCap!==null)? path.replace(/\d+/, page + 1) : "/page/2";
  }
    
} // handle_keyup() OUT


function set_up() {

  console.log("AAYYYY!");
  
  if (
   location.host.indexOf(".media.tumblr.")!==-1 
   && path.match(/_\d\d\d\d?\.[a-zA-Z0-9]{3,4}/)!==null
  ) {
  // if we're viewing an image at low rez - generally 500 or 540 if inline,
  // automatically bump it up to the high-rez version:
   location.replace(
     'http://' 
     + domain.replace(/..\.media.tumblr.com/,'data.tumblr.com')
     + path.replace(/_\d\d\d\d?\./,"_raw.") 
   );
  }
  
  window.addEventListener(
    "keyup",
    handle_keyup
  );

  document.addEventListener(
    "keyup",
    handle_keyup
  );

} // set_up() OUT