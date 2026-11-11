/*
 * Keeps the PDF/A validation box up to date while validation is still running.
 *
 * The box is rendered from persisted validation reports, but the page itself is only revalidated against the last
 * modification of the object, so a report that is written after the page was rendered never reaches the browser.
 * Re-fetching this page with the HTTP cache bypassed both picks up the finished reports and refreshes the cached
 * entry, so a later reload shows them too.
 *
 * A file added to, replaced in or removed from an existing derivate does not modify the object, so the browser may
 * show a cached page whose box misses such a change. Without pending files the PDF files listed in the box are
 * therefore compared once against the current derivate contents and the box is refreshed if they differ.
 */
(function () {
  "use strict";

  var CONTAINER_ID = "mir-pdfa-validation";
  var PENDING_SELECTOR = ".pdfa-status";
  var DELAYS = [5000, 10000, 20000, 30000];
  var MAX_ATTEMPTS = 12;

  var attempt = 0;
  var running = false;
  var timer = null;

  function container() {
    return document.getElementById(CONTAINER_ID);
  }

  function isPending(element) {
    return element !== null && element.querySelector(PENDING_SELECTOR) !== null;
  }

  function scheduleNext() {
    if (attempt >= MAX_ATTEMPTS) {
      return;
    }
    var delay = DELAYS[Math.min(attempt, DELAYS.length - 1)];
    attempt++;
    timer = window.setTimeout(refresh, delay);
  }

  function refresh(force) {
    if (running) {
      return;
    }
    var current = container();
    if (current === null || !(force === true || isPending(current))) {
      return;
    }
    running = true;
    window.clearTimeout(timer);
    current.classList.add("pdfa-refreshing");

    fetch(window.location.href, { cache: "reload", credentials: "same-origin" })
      .then(function (response) {
        if (!response.ok) {
          throw new Error("Unexpected status " + response.status);
        }
        return response.text();
      })
      .then(function (html) {
        var fresh = new DOMParser().parseFromString(html, "text/html").getElementById(CONTAINER_ID);
        if (fresh === null) {
          // not the expected page any more, for example a login form: leave the box alone
          return;
        }
        container().replaceWith(fresh);
        if (isPending(fresh)) {
          scheduleNext();
        }
      })
      .catch(function (error) {
        console.warn("[MIR] Could not refresh the PDF/A validation state.", error);
        scheduleNext();
      })
      .finally(function () {
        running = false;
        var box = container();
        if (box !== null) {
          box.classList.remove("pdfa-refreshing");
        }
      });
  }

  document.addEventListener("click", function (event) {
    var button = event.target.closest("[data-pdfa-refresh]");
    if (button !== null) {
      event.preventDefault();
      attempt = 0;
      refresh();
    }
  });

  function getToken(objectId, derivateIds) {
    var params = new URLSearchParams();
    [objectId].concat(derivateIds).forEach(function (id) {
      params.append("ua", "acckey_" + id);
      params.append("sa", "acckey_" + id);
    });
    return fetch(webApplicationBaseURL + "rsc/jwt?" + params, { cache: "no-store", credentials: "same-origin" })
      .then(function (response) {
        return response.ok ? response.json() : Promise.reject(new Error("Unexpected status " + response.status));
      })
      .then(function (data) {
        return data.login_success ? data : Promise.reject(new Error("No token: " + data.error));
      });
  }

  // resolves to a map "{derivateId}/{path}" -> modified of every PDF file of the derivate, walking all subdirectories
  function listPDFFiles(objectId, derivateId, token) {
    var result = new Map();
    var base = webApplicationBaseURL + "api/v2/objects/" + objectId + "/derivates/" + derivateId + "/contents";
    var headers = {
      Accept: "application/json",
      Authorization: token.token_type + " " + token.access_token
    };

    function walk(segments) {
      var path = segments.map(function (segment) {
        return "/" + encodeURIComponent(segment);
      }).join("");
      return fetch(base + path, { cache: "no-store", credentials: "same-origin", headers: headers })
        .then(function (response) {
          return response.ok ? response.json() : Promise.reject(new Error("Unexpected status " + response.status));
        })
        .then(function (directory) {
          (directory.files || []).forEach(function (file) {
            if (file.name.toLowerCase().endsWith(".pdf")) {
              result.set(derivateId + "/" + segments.concat(file.name).join("/"), file.modified);
            }
          });
          return Promise.all((directory.directories || []).map(function (child) {
            return walk(segments.concat(child.name));
          }));
        });
    }

    return walk([]).then(function () {
      return result;
    });
  }

  // current holds the PDF files of the checked derivates only
  function isStale(box, checked, current) {
    var shown = Array.prototype.filter.call(box.querySelectorAll("[data-pdfa-file]"), function (file) {
      return checked.has(file.dataset.pdfaDerivate);
    });
    if (shown.length !== current.size) {
      return true;
    }
    return shown.some(function (file) {
      var key = file.dataset.pdfaDerivate + "/" + file.dataset.pdfaFile;
      var modified = file.dataset.pdfaModified;
      return !current.has(key) || (modified !== undefined && modified !== current.get(key));
    });
  }

  // the page may come from the browser cache: compare its box with the current derivate contents once
  function checkFreshness(box) {
    var objectId = box.dataset.object;
    var derivateIds = (box.dataset.derivates || "").split(/\s+/).filter(Boolean);
    if (derivateIds.length === 0) {
      return;
    }
    var checked = new Set();
    var current = new Map();
    getToken(objectId, derivateIds)
      .then(function (token) {
        return Promise.all(derivateIds.map(function (derivateId) {
          // a derivate that cannot be listed, for example without read permission, is left out of the comparison
          return listPDFFiles(objectId, derivateId, token)
            .then(function (files) {
              checked.add(derivateId);
              files.forEach(function (modified, key) {
                current.set(key, modified);
              });
            })
            .catch(function (error) {
              console.warn("[MIR] Could not list the PDF files of " + derivateId + ".", error);
            });
        }));
      })
      .then(function () {
        if (isStale(box, checked, current)) {
          refresh(true);
        }
      })
      .catch(function (error) {
        console.warn("[MIR] Could not check whether the PDF/A validation state is up to date.", error);
      });
  }

  document.addEventListener("DOMContentLoaded", function () {
    var box = container();
    if (box === null) {
      return;
    }
    if (isPending(box)) {
      scheduleNext();
    } else {
      checkFreshness(box);
    }
  });
})();
