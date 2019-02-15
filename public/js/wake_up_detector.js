class WakeUpDetector {
  static WAKE_UP_TIME() { return 30000; }

  constructor(html) {
    this.lastInputTime = Date.now();
    this.html = html;

    this.html.addEventListener("mousemove", this.processPotentialWakeUp.bind(this));
    this.html.addEventListener("touchstart", this.processPotentialWakeUp.bind(this));
  }

  processPotentialWakeUp() {
    const now = Date.now();
    if((this.lastInputTime + WakeUpDetector.WAKE_UP_TIME()) < now) {
      this.wakeUp();
    }
    this.lastInputTime = now;
  }

  wakeUp() {
    this.html.classList.add("waking-up");
    const url = location.protocol + "//" + window.location.host + "/_/wake-up";
    return fetch(url, {
      method: "post",
      body: window.location.pathname,
      credentials: "include"
    }).then(function(response) {
      // 200 if there are changes, 204 if not.
      if(response.status === 200) {
        this.html.classList.add("not-saved");
      }
      this.html.classList.remove("waking-up");
    }.bind(this)).catch(function(err) {
      console.error(err);
    }.bind(this));
  }
}
