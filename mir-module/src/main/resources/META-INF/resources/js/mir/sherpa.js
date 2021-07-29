/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

(function () {
    function buildSimpleLink(url, text) {
        if(text===undefined){
            text = url;
        }
        return "<a href='" + url + "'>" + text + "</a>";
    }

    window.addEventListener('load', function () {
        let sherpaInfo = "data-sherpainfo-issn";
        let el = document.querySelector("[" + sherpaInfo + "]");
        if (el != null) {
            let issn = el.getAttribute(sherpaInfo);
            getPolicies(issn, function (url, links) {
                if (url !== undefined && links !== undefined) {
                    el.innerHTML = buildSimpleLink(url)
                    translate("mir.workflow.sherpa.message", function(message) {
                        el.innerHTML = buildSimpleLink(url, message);
                    });
                    /* if (links.length > 0) {
                        el.innerHTML += "<ul>" +
                            links.map(function (url) {
                                return "<li>" + buildSimpleLink(url) + "</li>";
                            }).join("") + "</ul>";
                    } */
                } else {
                    el.remove();
                }
            });
        }

    });

    function translate(i18nKey, onresolve) {
        let url = window["webApplicationBaseURL"] + "rsc/locale/translate/" + i18nKey;
        let xmlhttp = new XMLHttpRequest();
        xmlhttp.onreadystatechange = function () {
            if (this.readyState === 4 && this.status === 200) {
                onresolve(this.responseText);
            }

        }
        xmlhttp.open("GET", url, true);
        xmlhttp.send();
    }

    function getPolicies(issn, onresolve) {
        let baseUrl = window["webApplicationBaseURL"];
        let uriPart = "[[\"issn\",\"equals\",\"" + issn + "\"]]"
        let requestUrl = baseUrl + "rsc/sherpa/retrieve/publication?filter=" + encodeURIComponent(uriPart);
        let xmlhttp = new XMLHttpRequest();
        xmlhttp.onreadystatechange = function () {
            if (this.readyState === 4 && this.status === 200) {
                let response = JSON.parse(this.responseText);

                if (response["items"].length !== 1) {
                    onresolve();
                }

                let policies = response["items"][0]["publisher_policy"];
                onresolve("https://v2.sherpa.ac.uk/id/publication/" + response["items"][0]["id"], policies.map(function (policy) {
                    return policy["uri"];
                }));
            }
        };
        xmlhttp.open("GET", requestUrl, true);
        xmlhttp.send();
    }
})();