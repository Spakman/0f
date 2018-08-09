class HrefModal {
  constructor(element) {
    this.element = element;
    this.input = element.getElementsByTagName("input")[0];
    this.button = element.getElementsByTagName("button")[0];

    this.captureEvents();
  }

  captureEvents() {
    this.element.addEventListener("click", this.cancel.bind(this));
    this.element.addEventListener("keyup", this.handleInput.bind(this));
    this.input.addEventListener("keyup", this.handleInput.bind(this));
    this.button.addEventListener("click", this.submit.bind(this));
  }

  handleInput(ev) {
    ev.stopPropagation();
    if(ev.keyCode == 27) {
      this.cancel();
    }
    else if(ev.keyCode == 13) {
      this.submit();
    }
  }

  cancel() {
    this.hide();
    this.successCallback = undefined;
    if(this.cancelCallback) {
      this.cancelCallback.bind(this)();
    }
    this.cancelCallback = undefined;
  }

  submit() {
    if(this.successCallback) {
      this.successCallback.bind(this)(this.input.value);
    }
    this.successCallback = undefined;
    this.cancelCallback = undefined;
    this.hide();
  }

  capture(options) {
    this.input.placeholder = options.placeholder;
    this.input.value = options.value;
    this.successCallback = options.success;
    this.cancelCallback = options.cancel;
    this.show();
  }

  show() {
    this.element.classList.remove("hidden");
    this.input.focus();
    this.moveCursorToEndOfInput();
  }

  moveCursorToEndOfInput() {
    this.input.selectionStart = this.input.selectionEnd = this.input.value.length;
  }

  hide() {
    this.element.classList.add("hidden");
  }
}

class EditMenu {
  constructor(element, article, hrefModalElement, privateElement, moveElement, deleteElement, locationElement, styleElement, linkElement, closeElement) {
    this.element = element;
    this.article = article;

    this.hrefModal = new HrefModal(hrefModalElement);
    this.buildMenuObjects(privateElement, moveElement, deleteElement, locationElement, styleElement, linkElement, closeElement);

    this.listenToArticleEvents();
  }

  buildMenuObjects(privateElement, moveElement, deleteElement, locationElement, styleElement, linkElement, closeElement) {
    this.privateMenuEntry = new PrivateMenuEntry(privateElement);
    this.moveMenuEntry = new MoveMenuEntry(moveElement, this.hrefModal);
    this.deleteMenuEntry = new DeleteMenuEntry(deleteElement);
    this.locationMenuEntry = new LocationMenuEntry(locationElement, this.hrefModal);
    this.styleMenuEntry = new StyleMenuEntry(styleElement, { change: this.styleSelected.bind(this) });
    this.linkMenuEntry = new LinkMenuEntry(linkElement, this.hrefModal);
    this.closeMenuEntry = new CloseMenuEntry(closeElement, { click: this.closeClicked.bind(this) });
  }

  listenToArticleEvents() {
    this.article.addEventListener("startediting", this.show.bind(this));
    this.article.addEventListener("stopediting", this.hide.bind(this));
    this.article.addEventListener("cursorchanged", this.selectCurrentElementStyle.bind(this));
  }

  selectCurrentElementStyle() {
    this.styleMenuEntry.select(this.article.elementUnderCursor())
  }

  show() {
    this.element.classList.remove("hidden");
  }

  hide() {
    this.element.classList.add("hidden");
  }

  styleSelected(ev) {
    ev.preventDefault();
    ev.stopPropagation();

    let currentElement = this.article.elementUnderCursor();
    let selectedStyle = ev.target.value;

    if(selectedStyle == "UL" && currentElement != "UL") {
      document.execCommand('insertUnorderedList', false);
    }
    else if (selectedStyle != "UL" && currentElement == "UL") {
      document.execCommand('insertUnorderedList', false);
      document.execCommand("formatBlock", false, selectedStyle);
    }

    else {
      document.execCommand("formatBlock", false, selectedStyle);
    }
  };

  closeClicked(ev) {
    ev.preventDefault();
    ev.stopPropagation();
    this.article.stopEditing();
  }
}

class PrivateMenuEntry {
  constructor(element) {
    this.element = element;
    this.element.addEventListener("click", this.navigateToPrivate);
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
          window.location.href = value;
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
    let parts = window.location.pathname.split("/");
    parts.pop();
    return parts.join("/") + "/";
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
}

class LinkMenuEntry {
  constructor(element, hrefModal) {
    this.element = element;
    this.hrefModal = hrefModal;
    this.element.addEventListener("click", this.getHref.bind(this));
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

class CloseMenuEntry {
  constructor(element, callbacks) {
    this.callbacks = callbacks || {};
    this.element = element;
    if(this.callbacks.click) {
      this.element.addEventListener("click", this.callbacks.click);
    }
  }
}
