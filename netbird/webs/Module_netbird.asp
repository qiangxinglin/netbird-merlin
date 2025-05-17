<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>

<head>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
    <meta HTTP-EQUIV="Expires" CONTENT="-1">
    <link rel="shortcut icon" href="images/favicon.png">
    <link rel="icon" href="images/favicon.png">
    <title>软件中心 - NetBird</title>
    <link rel="stylesheet" type="text/css" href="index_style.css">
    <link rel="stylesheet" type="text/css" href="form_style.css">
    <link rel="stylesheet" type="text/css" href="css/element.css">
    <link rel="stylesheet" type="text/css" href="/js/table/table.css">
    <link rel="stylesheet" type="text/css" href="/res/softcenter.css">
    <script type="text/javascript" src="/js/jquery.js"></script>
    <script type="text/javascript" src="/state.js"></script>
    <script type="text/javascript" src="/general.js"></script>
    <script type="text/javascript" src="/popup.js"></script>
    <script type="text/javascript" src="/validator.js"></script>
    <script type="text/javascript" src="/js/table/table.js"></script>
    <script type="text/javascript" src="/res/softcenter.js"></script>
    <script type="text/javascript" src="/help.js"></script>
    <style>
        a:focus {
            outline: none;
        }

        .auth-link {
            color: #a52424 !important;
            font-weight: bold !important;
            text-decoration: none;
        }

        .SimpleNote {
            padding: 5px 5px;
        }

        i {
            color: #FC0;
            font-style: normal;
        }

        #return_btn {
            cursor: pointer;
            position: absolute;
            margin-left: -30px;
            margin-top: -25px;
        }

        .popup_bar_bg_ks {
            position: fixed;
            margin: auto;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 99;
            filter: alpha(opacity=90);
            background-repeat: repeat;
            visibility: hidden;
            overflow: hidden;
            background: rgba(68, 79, 83, 0.85) none repeat scroll 0 0 !important;
            background-position: 0 0;
            background-size: cover;
            opacity: .94;
        }

        .loading_block_spilt {
            background: #656565;
            height: 1px;
            width: 98%;
        }

        .content_status {
            position: absolute;
            border-radius: 10px;
            z-index: 10;
            margin-left: -415px;
            top: 0;
            left: 0;
            height: auto;
            box-shadow: 3px 3px 10px #000;
            background: rgba(0, 0, 0, 0.88);
            width: 948px;
            visibility: hidden;
        }

        .user_title {
            text-align: center;
            font-size: 18px;
            color: #99FF00;
            padding: 10px;
            font-weight: bold;
        }

        #nb_status,
        #nb_check {
            border: 0px solid #222;
            width: 98%;
            font-family: 'Lucida Console';
            font-size: 12px;
            padding-left: 13px;
            padding-right: 33px;
            background: transparent;
            color: #FFFFFF;
            outline: none;
            overflow-x: hidden;
            line-height: 1.5;
        }

        input[type=button]:focus {
            outline: none;
        }

        #log_content {
            border: 1px solid #000;
            width: 99%;
            font-family: 'Lucida Console';
            font-size: 11px;
            padding-left: 3px;
            padding-right: 22px;
            background: transparent;
            color: #FFFFFF;
            outline: none;
            overflow-x: hidden;
            line-height: 1.5;
        }

        .FormTitle em {
            color: #00ffe4;
            font-style: normal;
            font-weight: bold;
        }

        .FormTable th {
            width: 30%;
        }

        .formfonttitle {
            font-family: Roboto-Light, "Microsoft JhengHei";
            font-size: 18px;
            margin-left: 5px;
        }

        .FormTable_table {
            margin-top: 0px;
        }

        #app[skin=ASUSWRT] #netbird_main,
        #app[skin=ASUSWRT] #netbird_tcnets {
            outline: none;
        }

        #app[skin=ASUSWRT] .loadingBarBlock {
            width: 880px;
            outline: none;
        }

        #app[skin=ROG] #netbird_main,
        #app[skin=ROG] #netbird_tcnets {
            outline: 1px solid #91071f;
        }

        #app[skin=ROG] .loadingBarBlock {
            width: 880px;
            outline: 1px solid #91071f;
        }

        #app[skin=TUF] #netbird_main,
        #app[skin=TUF] #netbird_tcnets {
            outline: 1px solid #ffa523;
        }

        #app[skin=TS] #netbird_main,
        #app[skin=TS] #netbird_tcnets {
            outline: 1px solid #2ed9c3;
        }
    </style>
    <script>
        var params_chk = ['netbird_enable'];
        var refresh_flag;
        var count_down;
        var dbus = {};

        String.prototype.myReplace = function (f, e) {
            var reg = new RegExp(f, "g");
            return this.replace(reg, e);
        }

        function init() {
            show_menu(menu_hook);
            set_skin();
            get_dbus_data();
        }

        function set_skin() {
            var SKN = '<% nvram_get("sc_skin"); %>';
            if (SKN) {
                $("#app").attr("skin", '<% nvram_get("sc_skin"); %>');
            }
        }

        function get_dbus_data() {
            $.ajax({
                type: "GET",
                url: "/_api/netbird_",
                dataType: "json",
                async: false,
                success: function (data) {
                    dbus = data.result[0];
                    conf2obj();
                    register_event();
                    if (dbus["netbird_enable"] == "1") {
                        get_process_status();
                        show_hide_element();
                    }
                }
            });
        }

        function conf2obj() {
            for (var i = 0; i < params_chk.length; i++) {
                if (dbus[params_chk[i]]) {
                    E(params_chk[i]).checked = dbus[params_chk[i]] != "0";
                }
            }

            if (dbus["netbird_version"]) {
                E("netbird_version").innerHTML = " - " + dbus["netbird_version"];
            }
        }

        function show_hide_element() {
            E("netbird_status_tr").style.display = "";
        }

        function register_event() {
            $("#netbird_enable").click(
                function () {
                    if (dbus["netbird_enable"] == "1") {
                        E("netbird_enable").checked = false;
                    } else {
                        E("netbird_enable").checked = true;
                    }
                    save();
                });
        }

        function get_process_status() {
            var id = parseInt(Math.random() * 100000000);
            var postData = { "id": id, "method": "netbird_config.sh", "params": ["status"], "fields": "" };
            $.ajax({
                type: "POST",
                cache: false,
                url: "/_api/",
                data: JSON.stringify(postData),
                dataType: "json",
                success: function (response) {
                    if (response.result) {
                        var myResult = response.result;
                        if (myResult.startsWith("base64://")) {
                            myResult = myResult.myReplace("base64://", "");
                            myResult = decodeURIComponent(escape(window.atob(myResult)))
                        }
                        E("netbird_status").innerHTML = myResult;
                    }
                    setTimeout(() => get_process_status(), 5000);
                },
                error: function () {
                    setTimeout(() => get_process_status(), 15000);
                }
            });
        }

        function save() {
            var dbus_new = {};
            for (var i = 0; i < params_chk.length; i++) {
                dbus_new[params_chk[i]] = E(params_chk[i]).checked ? '1' : '0';
            }

            var id = parseInt(Math.random() * 100000000);
            var postData = { "id": id, "method": "netbird_config.sh", "params": ["web_submit"], "fields": dbus_new };
            $.ajax({
                type: "POST",
                url: "/_api/",
                data: JSON.stringify(postData),
                dataType: "json",
                success: function (response) {
                    if (response.result == id) {
                        get_log_auto_close();
                    }
                }
            });
        }

        function update() {
            var id = parseInt(Math.random() * 100000000);
            var postData = { "id": id, "method": "netbird_config.sh", "params": ["update"], "fields": {} };
            $.ajax({
                type: "POST",
                url: "/_api/",
                data: JSON.stringify(postData),
                dataType: "json",
                success: function (response) {
                    get_update_log();
                }
            });
        }

        function showWBLoadingBar() {
            document.scrollingElement.scrollTop = 0;
            E("loading_block_title").innerHTML = "&nbsp;&nbsp;NetBird日志信息";
            E("LoadingBar").style.visibility = "visible";
            var page_h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
            var page_w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
            var log_h = E("loadingBarBlock").clientHeight;
            var log_w = E("loadingBarBlock").clientWidth;
            var log_h_offset = (page_h - log_h) / 2;
            var log_w_offset = (page_w - log_w) / 2 + 95;
            $('#loadingBarBlock').offset({ top: log_h_offset, left: log_w_offset });
        }

        function hideWBLoadingBar() {
            E("LoadingBar").style.visibility = "hidden";
            E("ok_button").style.visibility = "hidden";
            if (refresh_flag == "1") {
                refreshpage();
            }
        }

        function count_down_close() {
            if (count_down == "0") {
                hideWBLoadingBar();
            }
            if (count_down < 0) {
                E("ok_button1").value = "手动关闭"
                return false;
            }
            E("ok_button1").value = "自动关闭（" + count_down + "）"
            --count_down;
            setTimeout("count_down_close();", 1000);
        }

        function get_log_auto_close() {
            get_log_internal("netbird_log", 6);
        }
        function get_log_never_close() {
            get_log_internal("netbird_log", -1);
        }
        function get_update_log() {
            get_log_internal("netbird_update_log", 6);
        }
        function get_log_internal(target_url, auto_close_seconds = 6) {
            E("ok_button").style.visibility = "hidden";
            showWBLoadingBar();
            var TARGET_URL = '/_temp/' + target_url + '.txt'
            $.ajax({
                url: TARGET_URL,
                type: 'GET',
                cache: false,
                dataType: 'text',
                success: function (response) {
                    var retArea = E("log_content");
                    if (response.search("XU6J03M6") != -1) {
                        retArea.value = response.myReplace("XU6J03M6", " ");
                        E("ok_button").style.visibility = "visible";
                        retArea.scrollTop = retArea.scrollHeight;
                        count_down = auto_close_seconds;
                        refresh_flag = 1;
                        count_down_close();
                        return false;
                    }
                    setTimeout(() => get_log_internal(target_url), 500);
                    retArea.value = response.myReplace("XU6J03M6", " ");
                    retArea.scrollTop = retArea.scrollHeight;
                }
            });
        }

        function menu_hook(title, tab) {
            tabtitle[tabtitle.length - 1] = new Array("", "netbird");
            tablink[tablink.length - 1] = new Array("", "Module_netbird.asp");
        } 
    </script>
</head>

<body id="app" skin="ASUSWRT" onload="init();">
    <div id="TopBanner"></div>
    <div id="Loading" class="popup_bg"></div>
    <div id="LoadingBar" class="popup_bar_bg_ks">
        <table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock" align="center">
            <tr>
                <td height="80">
                    <div id="loading_block_title" style="margin:10px auto;margin-left:10px;width:85%; font-size:12pt;">
                    </div>
                    <div id="loading_block_spilt" class="loading_block_spilt"></div>
                    <div style="width: 780px; margin-left:15px;margin-right:15px;margin-top:10px;overflow:hidden">
                        <textarea cols="50" rows="26" wrap="on" readonly="readonly" id="log_content" autocomplete="off"
                            autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
                    </div>
                    <div id="ok_button" class="apply_gen">
                        <input id="ok_button1" class="button_gen" type="button" onclick="hideWBLoadingBar()" value="确定">
                    </div>
                </td>
            </tr>
        </table>
    </div>

    <table class="content" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td width="17">&nbsp;</td>
            <td valign="top" width="202">
                <div id="mainMenu"></div>
                <div id="subMenu"></div>
            </td>
            <td valign="top">
                <div id="tabMenu" class="submenuBlock"></div>
                <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
                    <tr>
                        <td align="left" valign="top">
                            <table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3"
                                class="FormTitle" id="FormTitle">
                                <tr>
                                    <td bgcolor="#4D595D" colspan="3" valign="top">
                                        <div>&nbsp;</div>
                                        <div class="formfonttitle">NetBird<lable id="netbird_version"></lable>
                                        </div>
                                        <div style="float:right; width:15px; height:25px;margin-top:-20px">
                                            <img id="return_btn" onclick="reload_Soft_Center();" align="right"
                                                title="返回软件中心" src="/images/backprev.png"
                                                onMouseOver="this.src='/images/backprevclick.png'"
                                                onMouseOut="this.src='/images/backprev.png'"></img>
                                        </div>
                                        <div style="margin:10px 0 10px 5px;" class="splitLine"></div>
                                        <div class="SimpleNote">
                                            <span>NetBird是一款简单安全的自动化组网工具。</span>
                                            <span><a type="button" class="ks_btn" href="javascript:void(0);"
                                                    onclick="get_log_never_close()"
                                                    style="margin-left:5px;">详细状态</a></span>
                                            <span><a type="button" class="ks_btn" href="https://app.netbird.io"
                                                    target="_blank" style="margin-left:5px;">打开控制台</a></span>
                                            <span><a type="button" class="ks_btn" href="javascript:void(0);"
                                                    onclick="update()" style="margin-left:5px;">更新版本</a></span>
                                        </div>
                                        <div id="netbird_main">
                                            <table width="100%" border="1" align="center" cellpadding="4"
                                                cellspacing="0" class="FormTable">
                                                <thead>
                                                    <tr>
                                                        <td colspan="2">NetBird - 控制面板</td>
                                                    </tr>
                                                </thead>
                                                <tr id="switch_tr">
                                                    <th>服务开关</th>
                                                    <td>
                                                        <div class="switch_field">
                                                            <label for="netbird_enable">
                                                                <input id="netbird_enable" class="switch"
                                                                    type="checkbox" style="display: none;">
                                                                <div class="switch_container">
                                                                    <div class="switch_bar"></div>
                                                                    <div class="switch_circle transition_style">
                                                                        <div></div>
                                                                    </div>
                                                                </div>
                                                            </label>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr id="netbird_status_tr" style="display:none;">
                                                    <th>服务状态</th>
                                                    <td>
                                                        <div id="netbird_status"
                                                            style="font-family: emoji;white-space: pre-wrap;">检测中...
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
            <td width="10" align="center" valign="top"></td>
        </tr>
    </table>
    <div id="footer"></div>
</body>

</html>