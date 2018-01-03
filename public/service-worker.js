var CACHE_NAME = "fingers.today-mostly-passthrough";
var urlsToCache = [
  "/styles.css",
  "/edit-menu.css",
  "/contenteditable.js",
  "/door_theory_64.png",
  "/file_32.png",
  "/folder_32.png",
  "/close.png",
  "/secret.png"
];

self.addEventListener("install", function(ev) {
  ev.waitUntil(
    caches.open(CACHE_NAME).then(function(cache) {
      return cache.addAll(urlsToCache);
    })
  );
});

self.addEventListener("fetch", function(ev) {
  ev.respondWith(
    caches.match(ev.request).then(function(response) {
      return response || fetch(ev.request);
    })
  );
});
