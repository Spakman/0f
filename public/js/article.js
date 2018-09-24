class Article {
  constructor(element, clickableElement, body) {
    this.element = element;
    this.clickableElement = clickableElement;
    this.body = body;
    this.pageSaver = new PageSaver();
    this.ensureLinksAreClickable();
    this.makeElementEditable();
  }

  addEventListener(name, func) {
    this.element.addEventListener(name, func);
  }

  ensureLinksAreClickable() {
    Array.from(this.element.parentElement.getElementsByTagName("a")).forEach(function(a) {
      a.removeEventListener("click", this.stopPropagation);
      a.addEventListener("click", this.stopPropagation.bind(this));
    }.bind(this));
  }

  makeElementEditable() {
    this.clickableElement.addEventListener("click", function(ev) {
      if (ev.ctrlKey && ev.shiftKey) {
        window.location.href = "/private";
      } else if (ev.ctrlKey) {
        this.startEditing();
      }
    }.bind(this));

    this.clickableElement.addEventListener("touchstart", function(ev) {
      (ev.touches.length > 1) && this.startEditing();
    }.bind(this));

    this.element.addEventListener("input", this.inputReceived.bind(this));
  }

  inputReceived(ev) {
    this.save();
    this.cursorChanged();
  }

  cursorChanged() {
    this.element.dispatchEvent(new Event("cursorchanged"));
  }

  focus() {
    this.element.focus();
  }

  save() {
    this.pageSaver.save(this.element.innerHTML);
  }

  startEditing() {
    this.element.contentEditable = true;
    this.focus();
    this.body.classList.add("editing");
    this.clickableElement.classList.add("editing");
    this.element.dispatchEvent(new Event("startediting"));
    this.cursorChanged();
  }

  stopEditing() {
    this.element.blur();
    this.element.contentEditable = false;
    this.body.classList.remove("editing");
    this.clickableElement.classList.remove("editing");
    this.ensureLinksAreClickable();
    this.save();
    this.element.dispatchEvent(new Event("stopediting"));
  }

  stopPropagation(ev) {
    ev.stopPropagation();
  }

  elementUnderCursor() {
    let selection = window.getSelection();
    if (selection.rangeCount) {
      let selectionRange = selection.getRangeAt(0);
      let element = this.getContainer(selectionRange.endContainer);
      if(element) {
        return element.nodeName;
      }
      else { return "";
      }
    }
  }

  getContainer(node) {
    while (node) {
      if (node.nodeType == 1 && /^(P|H2|UL)$/i.test(node.nodeName)) {
        return node;
      }
      node = node.parentNode;
    }
  }
}
