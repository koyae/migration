function simulateMouseEvent(targetNode, events) {
    function triggerMouseEvent(targetNode, eventType) {
        var clickEvent = document.createEvent('MouseEvents');
        clickEvent.initEvent(eventType, true, true);
        targetNode.dispatchEvent(clickEvent);
    }
    events.forEach(function(eventType) {
        triggerMouseEvent(targetNode, eventType);
    });
}

// Above adapted from:
// https://stackoverflow.com/questions/24025165

var settingsButton = document.querySelector('button[aria-label="User Settings"]');
simulateMouseEvent(settingsButton, ["contextmenu"]);

var settingList = document.querySelectorAll('div div div[role="button"]');
var appearanceButton;
for (var i = 0; i < settingList.length; i++) {
    if (settingList[i].innerText == "Appearance") {
        var appearanceButton = settingList[i];
    }
}
simulateMouseEvent(appearanceButton, ["mouseover"]);

var appearanceOptions = document.querySelectorAll('div[role="button"] div div[role="button"]')
for (var i = 0; i < appearanceOptions.length; i++) {
    if (
	appearanceOptions[i].innerText.substr(0, 10) == "Switch to "
		&& appearanceOptions[i].innerText.substr(-6, 10) == " Theme"
	) {
        simulateMouseEvent(appearanceOptions[i], ["click"]);
    }
}

simulateMouseEvent(settingsButton, ["contextmenu"]);


