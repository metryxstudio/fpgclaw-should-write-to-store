___INFO___

{
  "type": "MACRO",
  "id": "fpgclaw_should_write_to_store",
  "version": 1,
  "securityGroups": [],
  "displayName": "FPGCLAW – Should Write to Store",
  "description": "Returns true if FPGCLAW should be written to Store (new gclid, first time, and within max age)",
  "containerContexts": [
    "SERVER"
  ],
  "categories": ["UTILITY"],
  "brand": {
    "id": "metryxstudio",
    "displayName": "Metryx Studio"
  },
  "termsOfService": {
    "accept": true
  }
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "currentFpgclaw",
    "displayName": "Current FPGCLAW (from Event Data)",
    "simpleValueType": true,
    "help": "Variable that reads custom_fpgclaw directly from event data (without Store fallback)"
  },
  {
    "type": "TEXT",
    "name": "storedFpgclaw",
    "displayName": "Stored FPGCLAW (from Store)",
    "simpleValueType": true,
    "help": "Variable that reads FPGCLAW from your key-value store (Firestore, Stape Store, etc.)"
  },
  {
    "type": "SELECT",
    "name": "maxAge",
    "displayName": "Max FPGCLAW Age",
    "selectItems": [
      { "value": "none", "displayValue": "No limit" },
      { "value": "30", "displayValue": "30 days" },
      { "value": "60", "displayValue": "60 days" },
      { "value": "90", "displayValue": "90 days" },
      { "value": "custom", "displayValue": "Custom" }
    ],
    "simpleValueType": true,
    "defaultValue": "none",
    "help": "Maximum age of FPGCLAW to be written to Store"
  },
  {
    "type": "TEXT",
    "name": "customMaxAge",
    "displayName": "Custom Max Age (days)",
    "simpleValueType": true,
    "enablingConditions": [
      { "paramName": "maxAge", "paramValue": "custom", "type": "EQUALS" }
    ],
    "help": "Enter number of days"
  }
]


___SANDBOXED_JS_FOR_SERVER___

var getTimestampMillis = require('getTimestampMillis');
var makeNumber = require('makeNumber');
var makeString = require('makeString');

var current = data.currentFpgclaw;
var stored = data.storedFpgclaw;
var maxAge = data.maxAge;
var customMaxAge = data.customMaxAge;

if (!current) return false;

// Parse gclid: "2.1.kTEST12345$i1767170762" -> "TEST12345"
var parseGclid = function(fpgclaw) {
  var s = makeString(fpgclaw);
  var dotParts = s.split('.');
  if (dotParts.length < 3) return null;
  
  var dollarParts = dotParts[2].split('$');
  var payload = dollarParts[0];
  if (!payload || payload.length < 2) return null;
  
  // Remove first char (k prefix) using substring
  return payload.substring(1);
};

// Parse timestamp: "2.1.kTEST12345$i1767170762" -> 1767170762000
var parseTimestampMs = function(fpgclaw) {
  var s = makeString(fpgclaw);
  var parts = s.split('$i');
  if (parts.length < 2) return null;
  
  var tail = parts[1];
  if (!tail) return null;
  
  // Extract only digits using charAt loop (regex not reliable in sandbox)
  var digits = '';
  for (var i = 0; i < tail.length; i++) {
    var c = tail.charAt(i);
    if (c >= '0' && c <= '9') {
      digits = digits + c;
    } else {
      break;
    }
  }
  
  if (!digits) return null;
  
  var secs = makeNumber(digits);
  if (secs <= 0) return null;
  
  return secs * 1000;
};

// Max-age check
if (maxAge !== 'none') {
  var clickMs = parseTimestampMs(current);
  
  if (clickMs) {
    var maxDaysNum;
    
    if (maxAge === 'custom') {
      maxDaysNum = makeNumber(customMaxAge);
      if (maxDaysNum <= 0) {
        maxDaysNum = 30;
      }
    } else {
      maxDaysNum = makeNumber(maxAge);
    }
    
    var maxAgeMs = maxDaysNum * 24 * 60 * 60 * 1000;
    var now = getTimestampMillis();
    
    if ((now - clickMs) > maxAgeMs) return false;
  }
}

// Parse and compare gclid
var currentGclid = parseGclid(current);
if (!currentGclid) return false;

if (!stored) return true;

var storedGclid = parseGclid(stored);
if (!storedGclid) return true;

return currentGclid !== storedGclid;


___SERVER_PERMISSIONS___

[

]


___TESTS___

scenarios: []
