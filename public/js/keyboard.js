class Keyboard {
  constructor(body, article, editMenu) {
    this.body = body;
    this.article = article;
    this.editMenu = editMenu;
    this.setupListeners();
  }

  setupListeners() {
    this.body.addEventListener("keypress", function(ev) {
      if(this.article.editing()) {
        // escape cancels editing
        if(ev.keyCode == 27) {
          this.article.stopEditing();
        }
        // arrow keys
        else if(ev.keyCode == 37 || ev.keyCode == 38 || ev.keyCode == 39 || ev.keyCode == 40) {
          this.article.cursorChanged();
        }
        // right-alt-l opens the link dialog
        else if(ev.charCode == 322) {
          ev.preventDefault();
          this.editMenu.linkMenuEntry.click();
        }
        // right-alt-h styles the current block as a heading
        else if(ev.charCode == 295) {
          ev.preventDefault();
          this.editMenu.styleMenuEntry.h2();
        }
        // right-alt-p styles the current block as a paragraph
        else if(ev.charCode == 254) {
          ev.preventDefault();
          this.editMenu.styleMenuEntry.p();
        }
        // right-alt-h styles the current block as an unordered list
        else if(ev.charCode == 8595) {
          ev.preventDefault();
          this.editMenu.styleMenuEntry.ul();
        }
        // right-alt-a opens the add page dialog
        else if(ev.charCode == 230) {
          ev.preventDefault();
          this.editMenu.locationMenuEntry.click();
        }
      }
      else {
        // h navigates to /
        if(ev.charCode == 104) {
          ev.preventDefault();
          window.location.href = "/";
        }
        // p navigates to /private/
        else if(ev.charCode == 112) {
          ev.preventDefault();
          this.editMenu.privateMenuEntry.click();
        }
        // right-alt-a opens the add page dialog
        else if(ev.charCode == 230) {
          ev.preventDefault();
          this.article.startEditing();
          this.editMenu.locationMenuEntry.click();
        }
        // a navigates to /
        else if(ev.charCode == 97) {
          ev.preventDefault();
          this.article.startEditing();
          this.editMenu.locationMenuEntry.click();
        }
      }
    }.bind(this));
  }
}
