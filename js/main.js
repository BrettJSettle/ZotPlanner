var reload = false;

function toggleLogin() {
    if ($("#toggleLogin").val() == "Logout") {
        $("#ucinetid").val("");
        $("#password").val("");
        $("#degreeworks-response").contents().find("html").html("");
        $("#degreeworks-button").text("Degreeworks");
        $("#degreeworks")[0].style["display"] = "none";
    }
    $("#toggleLogin").val("Login");
    reload = true;
    $("#login-modal").toggle();
    $("#ucinetid").focus();
}

function get_listings(ev) {
    let data = {mode: 'search'}
    $("#websoc-form").serializeArray().map(function(v) { data[v.name] =v.value;} )
    show_listings(data)
}

function toggleDegreeWorks() {
    $("#login-modal")[0].style["display"] = "none";
    if ($("#degreeworks")[0].style["display"] != "none") {
        $("#degreeworks")[0].style["display"] = "none";
        $("#degreeworks-button")[0].innerText = "DegreeWorks";
        return;
    }

    var ucinetid = $("#ucinetid").val(),
        password = $("#password").val();
    if (ucinetid == "" || password == "") {
        loginMessage("Must provide a ucinetid and password");
        return;
    }
    $("#degreeworks-button")[0].disabled = true;
    $("#degreeworks-button")[0].innerText = "Loading";
    var data = {
        "ucinetid": ucinetid,
        "password": password,
        "mode": "Degreeworks"
    };
    degreeworks(data);

}

function show_listings(data) {
    if ($("#webreg-button").text() == "WebSOC") {
        $("#webreg").toggle();
        $("#webreg-button").text($("#webreg-button").text() == "WebSOC" ? "WebReg" : "WebSOC");
    }

    $("#search-message")[0].innerHTML = "Loading";
    var posting = $.post("/cgi-bin/zotplanner/search.py", data);
    posting.done(function(data) {
        if (data.search("ERROR:") >= 0) {
            $("#search-message")[0].innerHTML = data.substr(7);
            return;
        }
        $("#search-message")[0].innerHTML = "";
        $(".course-list table")[0].innerHTML = data + $(".course-list table")[0].innerHTML;

        $(".course-list table td .toggle").click(function(ev) {
            ev.target.src = ev.target.src.search("down-128.png") >= 0 ? "media/up-128.png" : "media/down-128.png";
            var tar = ev.target.parentElement.parentElement.parentElement.children;
            for (var i = 1; i < tar.length; i++) {
                $(tar[i]).toggle()
            }
        });

        $(".course-list table td .remove").click(function(ev) {
            var tar = ev.target.parentElement.parentElement.parentElement;
            $(tar).remove();
        });
        linkRows();

    });
}

function get_search() {
    var posting = $.post("/cgi-bin/zotplanner/search.py", {
        "mode": "load"
    });
    posting.done(function(data) {
        $("#websoc-search")[0].innerHTML = data;
        $("#search")[0].onclick = get_listings;
        $("#clearSearch")[0].onclick = function(ev) {
            $(".course-list table tbody").remove();
        };
    });
}

function linkRows() {
    var $listingContext = $(".course-list table");
    var $courseRow = $("tr[valign*='top']:not([bgcolor='#fff0ff'])", $listingContext);

    // FIXME: hover() deprecated
    $courseRow.hover(
        function() {
            $(this).css({
                "color": "#ff0000",
                "cursor": "pointer"
            });
        },
        function() {
            $(this).css({
                "color": "#000000",
                "cursor": "default"
            });
        }
    );

    $courseRow.on("click", function() {
        var timeString = $(this).find("td").eq(LISTING_TIME_INDEX).html();

        // Ignore if course is "TBA"
        if (timeString.indexOf("TBA") != -1) {
            alert("Course is TBA");
            return;
        }

        var courseCode = $(this).find("td").eq(LISTING_CODE_INDEX).text();
        // Ignore if course already added
        if (isCourseAdded(courseCode)) {
            alert("You have already added that course!");
            return;
        }

        var courseName = $.trim($(this).prevAll().find(".CourseTitle:last").html().split("<font")[0].replace(/&nbsp;/g, ""));
        var courseTimes = new CourseTimeStringParser(timeString)
        var roomString = $(this).find("td").eq(LISTING_ROOM_INDEX).html();
        var rooms = parseRoomString(roomString);

        // Iterate through course times (a course may have different meeting times)
        for (var i in courseTimes) {
            var parsed = courseTimes[i];
            $("#cal").weekCalendar("scrollToHour", parsed.beginHour, true);

            if (i in rooms && rooms[i].length > 0) {
                var room = rooms[i];
            } else {
                // Is there a possibility that there is only one room listed for all times (in the case of multiple times)?
                var room = "TBA";
            }

            for (var i in parsed.days) {
                var day = parsed.days[i];

                calEvent = {
                    id: S4(),
                    groupId: courseCode,
                    start: new Date(APP_YEAR, APP_MONTH, day, parsed.beginHour, parsed.beginMin),
                    end: new Date(APP_YEAR, APP_MONTH, day, parsed.endHour, parsed.endMin),
                    title: courseName + " at " + room + "<br>(" + courseCode + ")"
                }
                $("#cal").weekCalendar("updateEvent", calEvent);
            }
        }

        // Assign a color to the courses
        var colorPair = getRandomColorPair();
        $(".wc-cal-event").each(function(index, el) {
            var c = $(el).data().calEvent
            if (c.groupId.indexOf(courseCode) != -1) {
                colorEvent(el, colorPair);
            }
        });
    });
}


function registerMessage(message) {
    message = message || "";
    $("#registerMessage")[0].innerHTML = message;
}


function addRegCode(code) {
    var ch = $("#courseCodes").children();
    for (var i = 0; i < ch.length; i++) {
        var b = ch[i];
        if (b.value == code) {
            return;
        }
    }
    var newOpt = $("<option>", {
        value: code,
        text: code
    });
    $(newOpt).on("click", function(a) {
        removeRegCode(code);
    })
    $("#courseCodes").append(newOpt);
}

function removeRegCode(code) {
    $("#courseCodes").children().each(function(a, b) {
        if (b.value == code) {
            $("#courseCodes")[0].removeChild(b);
        }
    });
}

function degreeworks(data) {
    if (!reload) {
        $('#degreeworks')[0].style['display'] = '';
        $("#degreeworks-button")[0].innerText = "Calendar";
        $("#degreeworks-button")[0].disabled = false;
        return;
    }
    var posting = $.post("/cgi-bin/zotplanner/webauth.py", data);
    posting.done(function(data) {
        $("#degreeworks-button")[0].disabled = false;
        if (data.startsWith("ERROR")) {
            loginMessage(data);

            $("#degreeworks-button")[0].innerText = "Degreeworks";
            return;
        }
        $('#degreeworks')[0].style['display'] = '';
        $("#degreeworks-button")[0].innerText = "Calendar";

        $("#degreeworks-response").contents().find("html").html(data);
        connectDW();
        reload = false;
        $("#toggleLogin").val("Logout");
    });
}

function connectDW() {
    var doc = $("#degreeworks-response").contents();
    $("span, td.courseapplieddatadiscnum", doc).on("click", function(ev) {
        
	var disc = this.getAttribute("disc"),
            num = this.getAttribute("num");
        var yearTerm = document.getElementsByName("YearTerm")[0].value;
        show_listings({
            "mode": "search",
            "Dept": disc,
            "CourseNum": num,
            "YearTerm": yearTerm
        });
    });

    $("tr.bgLight100, tr.bgLight0, tr.bgLight98, tr.bgLight99", doc).on("click", function(ev) {
        listings = {};
        var spans = $("span", this);
        var yearTerm = document.getElementsByName("YearTerm")[0].value;
        if (spans.length == 0) {
            spans = $("td.courseapplieddatadiscnum", this);
        }
        for (var i = 0; i < spans.length; i++) {
            var disc = spans[i].getAttribute("disc"),
                num = spans[i].getAttribute("num");
            if (!listings.hasOwnProperty(disc))
                listings[disc] = num;
            else
                listings[disc] += ", " + num;
        }
        for (var disc in listings) {
            show_listings({
                "mode": "search",
                "Dept": disc,
                "CourseNum": listings[disc],
                "YearTerm": yearTerm
            });
        }
    });
}

$(document).ready(function() {
    /*$("#addCodeEntry")[0].onclick = function(ev) {
    	var code = $("#codeEntry");
    	alert(code.val());
    	var newOpt = $("<option>", {
            value: code.val(),
            text: code.val()
    	});
    	$(newOpt).on("click", function(a) {
            removeRegCode(code);
   	});
    	$("#courseCodes").append(newOpt);
    	code.val("");
    };
    */
    $("#cal").weekCalendar({
        businessHours: {
            start: 6,
            end: 24,
            limitDisplay: true
        },
        showHeader: false,
        showColumnHeaderDate: false,
        timeslotsPerHour: 3,
        daysToShow: 5,
        readonly: true,
        useShortDayNames: true,
        allowCalEventOverlap: true,
        overlapEventsSeparate: true,
        buttons: false,
        height: function($calendar) {
            return $(window).height() - $("#upper").outerHeight();
        },
        draggable: function(calEvent, element) {
            return false;
        },
        resizable: function(calEvent, element) {
            return false;
        },
        eventClick: function(calEvent, element) {
            if ($("#webreg")[0].style["display"] == "none") {
                if ($("#degreeworks-button").text() == "Calendar") {
                    toggleDegreeWorks();
                }
                var delCode = calEvent.groupId;
                removeRegCode(delCode);
                $(".wc-cal-event").each(function(index, el) {
                    var c = $(el).data().calEvent
                    if (c.groupId == delCode) {
                        $("#cal").weekCalendar("removeEvent", c.id);
                    }
                });
            } else {
                addRegCode(calEvent.groupId);
            }
        }
    });

    $("#cal").weekCalendar("gotoWeek", new Date(APP_YEAR, APP_MONTH, APP_DAY));

    $("#sendRequest, #studyList").click(function(event) {
        registerMessage("");
	$(".action").attr("disabled", "");
        var data = $("#registerForm").serializeArray().reduce(function(obj, item) {
            obj[item.name] = item.value;
            return obj;
        }, {});
        data["courseCodes"] = "";
        var ch = $("#courseCodes").children();
        for (var i = 0; i < ch.length; i++) {
            data["courseCodes"] += ch[i].value + " ";
        }
        if (event.target.value != "Study List" && data["courseCodes"] == "") {
            $(".action").removeAttr("disabled");
            registerMessage("No classes listed");
            return;
        }
        data.ucinetid = $("#ucinetid").val();
        data.password = $("#password").val();
        if (data.password == "" || data.ucinetid == "") {
            loginMessage("Not logged in to WebReg.");
            $(".action").removeAttr("disabled");
            return;
        }

        data.submit = event.target.value;
        var posting = $.post("/cgi-bin/zotplanner/register.py", data);
        posting.done(function(data) {
            registerMessage(data);
            $(".action").attr("disabled", null);
        });
    });

    $("#save-btn").on("click", function() {
        var calData = JSON.stringify($("#cal").weekCalendar("serializeEvents"));
        console.log(calData);
        //var defaultName = localStorage.username ? localStorage.username : ";
        var username = prompt("Please enter a unique username (e.g. Student ID): ", "");

        // Validation
        if (username == null) {
            return;
        }

        if (username.length < 5) {
            alert("Username must be at least 5 characters.")
            return;
        }

        // Save to server
        $.ajax({
            url: "/cgi-bin/zotplanner/schedule.py",
            type: "post",
            data: {
                username: username,
                data: calData
            },
            success: function(data) {
                if (data.search("ERROR") == -1) {
                    alert("Schedule successfully saved!");
                    localStorage.username = username;
                } else {
                    alert("Problem saving schedule. " + data);
                }
            }
        });
    });

    $("#load-btn").on("click", function() {
        var defaultName = localStorage.username ? localStorage.username : "";
        var username = prompt("Please enter your username", defaultName);

        if (username == "") {
            return;
        }

        $.ajax({
            url: "/cgi-bin/zotplanner/schedule.py",
            data: {
                username: username
            },
            success: function(data) {
                if (data.search("ERROR") == -1) {
                    $("#cal").weekCalendar("clear");
                    $("#cal").weekCalendar("loadEvents", JSON.parse(data));
                    groupColorize();
                    alert("Schedule successfully loaded!");
                } else {
                    alert("Problem loading schedule. " + data);
                }
            }
        });
    });

    $("#clear-cal-btn").on("click", function() {
        $("#cal").weekCalendar("clear");
    });

    // TODO: toggle() deprecated
    $("#resize-btn").toggle(function() {
        $(this).addClass("active");
        $("#left").animate({
            width: "100%"
        });
    }, function() {
        $("#left").animate({
            width: "50%"
        });
        $(this).removeClass("active");
    });

    $("#webreg-button").on("click", function(ev) {
        data = {
            "ucinetid": $("#ucinetid").val(),
            "password": $("#password").val()
        };
        if ($("#webreg-button").text() == "WebReg" && (data["ucinetid"] == "" || data["password"] == "")) {
            loginMessage("Must provide UCInetId and password");
            return;
        }
        $("#webreg").toggle();
        $("#webreg-button").text($("#webreg-button").text() == "WebSOC" ? "WebReg" : "WebSOC");
    });

    $("#login").on("click", function() {
        $("#login_status_span")[0].style["visibility"] = "";
        loginMessage("");
        var ucinetid = $("#ucinetid").val(),
            password = $("#password").val();
        if (ucinetid == "" || password == "") {
            loginMessage("Login with your UCInetID and password");
            $("#login_status_span")[0].style["visibility"] = "hidden";
            return;
        }
        data = {
            "ucinetid": ucinetid,
            "password": password,
            mode: "Login"
        }
        var posting = $.post("/cgi-bin/zotplanner/webauth.py", data);
        posting.done(function(data) {
            $("#login_status_span")[0].style["visibility"] = "hidden";
            if (data.search("ERROR") == -1) {
                toggleLogin();
                $("#toggleLogin").val("Logout");
            } else {
                loginMessage(data);
            }
        });
    });


    $("#password").keydown(function(ev) {
        if (ev.keyCode == 13) {
            $("#login").click();
        }
    });
    get_search();
});


function loginMessage(message) {
    if ($("#login-modal")[0].style["display"] == "none") {
        toggleLogin();
    }
    $(".login-error").text(message);
}
