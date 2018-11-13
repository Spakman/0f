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
  constructor(element, article, hrefModalElement, privateElement, moveElement, deleteElement, locationElement, styleElement, linkElement, shareElement, closeElement) {
    this.element = element;
    this.article = article;

    this.hrefModal = new HrefModal(hrefModalElement);
    this.buildMenuObjects(privateElement, moveElement, deleteElement, locationElement, styleElement, linkElement, shareElement, closeElement);

    this.listenToArticleEvents();
  }

  buildMenuObjects(privateElement, moveElement, deleteElement, locationElement, styleElement, linkElement, shareElement, closeElement) {
    this.privateMenuEntry = new PrivateMenuEntry(privateElement);
    this.moveMenuEntry = new MoveMenuEntry(moveElement, this.hrefModal);
    this.deleteMenuEntry = new DeleteMenuEntry(deleteElement);
    this.locationMenuEntry = new LocationMenuEntry(locationElement, this.hrefModal);
    this.styleMenuEntry = new StyleMenuEntry(styleElement, { change: this.styleSelected.bind(this) });
    this.linkMenuEntry = new LinkMenuEntry(linkElement, this.hrefModal);
    this.shareMenuEntry = new ShareMenuEntry(shareElement, { success: this.closeClicked.bind(this) });
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
    if(ev) {
      ev.preventDefault();
      ev.stopPropagation();
    }
    this.article.stopEditing();
  }
}
