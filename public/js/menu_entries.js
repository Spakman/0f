class PrivateMenuEntry {
  constructor(element) {
    this.element = element;
    this.element.addEventListener("click", this.navigateToPrivate);
  }

  click() {
    this.element.click();
  }

  navigateToPrivate(ev) {
    ev.preventDefault();
    ev.stopPropagation();
    window.location.href = "/private/";
  }
}

class MoveMenuEntry {
  constructor(element, hrefModal) {
    this.element = element;
    this.hrefModal = hrefModal;
    if (element) {
      this.element.addEventListener("click", this.getHref.bind(this));
    }
  }

  click() {
    this.element.click();
  }

  getHref(ev) {
    ev.preventDefault();
    ev.stopPropagation();
    this.hrefModal.capture({
      placeholder: "Move to path",
      value: window.location.pathname,
      success: function(value) {
        return fetch(value, {
          method: "post",
          body: window.location.pathname.substring(1),
          credentials: "include"
        }).then(function(response) {
          if (response.status == 200) {
            window.location.href = value;
          }
          else {
            alert("Target already exists!");
          }
        }).catch(function(err) {
          console.error(err);
        });
      }
    });
  }

  currentDirname() {
    let parts = window.location.pathname.split("/");
    parts.pop();
    return parts.join("/") + "/";
  }
}

class DeleteMenuEntry {
  constructor(element) {
    if(element) {
      this.element = element;
      this.element.addEventListener("click", this.confirmDelete.bind(this))
    }
  }

  click() {
    this.element.click();
  }

  confirmDelete(ev) {
    ev.preventDefault();
    ev.stopPropagation();
    if(window.confirm("Delete this page?")) {
      return fetch(document.URL, {
        method: "delete",
        credentials: "include"
      }).catch(function(err) {
        console.error(err);
      }).then(function(response) {
        if(response.redirected) {
          window.location.href = response.url;
        }
        else {
          console.error(response);
        }
      });
    }
  }
}

class LocationMenuEntry {
  constructor(element, hrefModal) {
    this.element = element;
    this.hrefModal = hrefModal;
    this.element.addEventListener("click", this.getHref.bind(this));
  }

  click() {
    this.element.click();
  }

  getHref(ev) {
    ev.preventDefault();
    ev.stopPropagation();
    this.hrefModal.capture({
      placeholder: "Go to location",
      value: this.currentDirname(),
      success: function(value) {
        window.location.href = value;
      }
    });
  }

  currentDirname() {
    return this.element.dataset.directory;
  }
}

class StyleMenuEntry {
  constructor(element, callbacks) {
    this.callbacks = callbacks || {};
    this.element = element;
    if(this.callbacks.change) {
      this.element.addEventListener("change", this.callbacks.change);
    }
  }

  select(value) {
    this.element.value = value;
  }

  h2() {
    this.element.value = "H2";
    this.element.dispatchEvent(new Event("change"));
  }

  p() {
    this.element.value = "P";
    this.element.dispatchEvent(new Event("change"));
  }

  ul() {
    this.element.value = "UL";
    this.element.dispatchEvent(new Event("change"));
  }
}

class LinkMenuEntry {
  constructor(element, hrefModal) {
    this.element = element;
    this.hrefModal = hrefModal;
    this.element.addEventListener("click", this.getHref.bind(this));
  }

  click() {
    this.element.click();
  }

  getHref(ev) {
    ev.preventDefault();
    ev.stopPropagation();
    this.selectionToLink = this.saveSelection();
    this.hrefModal.capture({
      placeholder: "href target",
      value: "",
      success: function(value) {
        this.restoreSelection(this.selectionToLink);
        document.execCommand('createLink', false, value);
      }.bind(this),
      cancel: function() {
        this.restoreSelection(this.selectionToLink);
      }.bind(this)
    });
  }

  saveSelection() {
    var sel = window.getSelection();
    if(sel.getRangeAt && sel.rangeCount) {
      var ranges = [];
      for(var i = 0, len = sel.rangeCount; i < len; ++i) {
        ranges.push(sel.getRangeAt(i));
      }
      return ranges;
    }
    return null;
  }

  restoreSelection(savedSel) {
    var sel = window.getSelection();
    sel.removeAllRanges();
    if(savedSel) {
      for(var i = 0, len = savedSel.length; i < len; ++i) {
        sel.addRange(savedSel[i]);
      }
    }
  }
}

class ShareMenuEntry {
  constructor(element, callbacks) {
    this.element = element;
    this.callbacks = callbacks;
    if(navigator.share !== undefined) {
      this.element.addEventListener("click", this.shareURI.bind(this))
    }
    else {
      this.element.parentElement.remove();
    }
  }

  shareURI(ev) {
    ev.preventDefault();
    navigator.share({title: "", text: "", url: window.location.href})
      .then(function() {
        console.log("Share success!");
        if(this.callbacks.success) {
          this.callbacks.success();
        }
      }.bind(this))
      .catch(function() {
        console.log("Share failure!");
        if(this.callbacks.failure) {
          this.callbacks.failure();
        }
      }.bind(this));
  }
}

class CloseMenuEntry {
  constructor(element, callbacks) {
    this.callbacks = callbacks || {};
    this.element = element;
    if(this.callbacks.click) {
      this.element.addEventListener("click", this.callbacks.click);
    }
  }
}
