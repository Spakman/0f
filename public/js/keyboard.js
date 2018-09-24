class Keyboard {
  constructor(body, article, editMenu) {
    this.body = body;
    this.article = article;
    this.editMenu = editMenu;
    this.setupListeners();
  }

  setupListeners() {
    this.body.addEventListener("keypress", function(ev) {
      if(ev.keyCode == 27) {
        this.article.stopEditing();
      }
      else if(ev.keyCode == 37 || ev.keyCode == 38 || ev.keyCode == 39 || ev.keyCode == 40) {
        this.article.cursorChanged();
      }
      else if(ev.charCode == 322) {
        ev.preventDefault();
        this.editMenu.linkMenuEntry.click();
      }
      else if(ev.charCode == 295) {
        ev.preventDefault();
        this.editMenu.styleMenuEntry.h2();
      }
      else if(ev.charCode == 254) {
        ev.preventDefault();
        this.editMenu.styleMenuEntry.p();
      }
      else if(ev.charCode == 8595) {
        ev.preventDefault();
        this.editMenu.styleMenuEntry.ul();
      }
    }.bind(this));
  }
}
