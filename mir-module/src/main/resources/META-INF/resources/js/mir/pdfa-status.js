/*
 * Keeps the PDF/A validation box up to date while validation is still running.
 *
 * The box is rendered from persisted validation reports, but the page itself is only revalidated against the last
 * modification of the object, so a report that is written after the page was rendered never reaches the browser.
 * Re-fetching this page with the HTTP cache bypassed both picks up the finished reports and refreshes the cached
 * entry, so a later reload shows them too.
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

  function refresh() {
    if (running) {
      return;
    }
    var current = container();
    if (!isPending(current)) {
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

  document.addEventListener("DOMContentLoaded", function () {
    if (isPending(container())) {
      scheduleNext();
    }
  });
})();
