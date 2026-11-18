/* Offline cache for the prototype PWA. Bump CACHE when the asset list changes. */
const CACHE = "i-quit-pwa-v2";
const ASSETS = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./css/base.css",
  "./css/screens.css",
  "./js/data.js",
  "./js/i18n.js",
  "./js/app.js",
  "./js/ui-core.js",
  "./js/ui-home.js",
  "./js/ui-timeline.js",
  "./js/ui-progress.js",
  "./js/ui-settings.js",
  "./js/ui-onboarding.js",
  "./js/ui-sheet.js",
  "./js/main.js",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/apple-touch-icon.png"
];

self.addEventListener("install", function (event) {
  event.waitUntil(
    caches.open(CACHE)
      .then(function (cache) { return cache.addAll(ASSETS); })
      .then(function () { return self.skipWaiting(); })
  );
});

self.addEventListener("activate", function (event) {
  event.waitUntil(
    caches.keys()
      .then(function (keys) {
        return Promise.all(keys.filter(function (key) { return key !== CACHE; })
          .map(function (key) { return caches.delete(key); }));
      })
      .then(function () { return self.clients.claim(); })
  );
});

function cacheResponse(request, response) {
  if (response && response.ok && response.type === "basic") {
    const copy = response.clone();
    return caches.open(CACHE)
      .then(function (cache) { return cache.put(request, copy); })
      .then(function () { return response; });
  }
  return Promise.resolve(response);
}

self.addEventListener("fetch", function (event) {
  const request = event.request;
  if (request.method !== "GET") return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request)
        .then(function (response) { return cacheResponse(request, response); })
        .catch(function () {
          return caches.match(request, { ignoreSearch: true })
            .then(function (cached) { return cached || caches.match("./index.html"); });
        })
    );
    return;
  }

  const network = fetch(request)
    .then(function (response) { return cacheResponse(request, response); })
    .catch(function () { return null; });

  event.waitUntil(network);

  event.respondWith(
    caches.match(request, { ignoreSearch: true }).then(function (cached) {
      if (cached) return cached;
      return network.then(function (response) {
        return response || Response.error();
      });
    })
  );
});
