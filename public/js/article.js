class Article {
  constructor(element, mainElement, body) {
    this.element = element;
    this.mainElement = mainElement;
    this.pageSaver = new PageSaver();
    this.ensureLinksAreClickable();
    this.makeElementEditable();
    this.body = body;
  }

  addEventListener(name, func) {
    this.element.addEventListener(name, func);
  }

  ensureLinksAreClickable() {
    Array.from(this.element.parentElement.getElementsByTagName("a")).forEach(function(a) {
      a.removeEventListener("click", this.stopPropagation);
      a.addEventListener("click", this.stopPropagation);
    }.bind(this));
  }

  makeElementEditable() {
    this.element.addEventListener("click", this.startEditing.bind(this));
    this.mainElement.addEventListener("click", this.startEditing.bind(this));

    this.element.addEventListener("keyup", function(ev) {
      if(ev.keyCode == 27) {
        this.stopEditing();
      }
      else if(ev.keyCode == 37 || ev.keyCode == 38 || ev.keyCode == 39 || ev.keyCode == 40) {
        this.cursorChanged();
      }
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
    this.element.dispatchEvent(new Event("startediting"));
    this.cursorChanged();
  }

  stopEditing() {
    this.element.blur();
    this.element.contentEditable = false;
    this.body.classList.remove("editing");
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
