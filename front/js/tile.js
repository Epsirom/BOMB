function Tile(position, value, isNew) {
    this.x                = position.x;
    this.y                = position.y;
    this.value            = value == undefined ? 2 : value;

    this.previousPosition = null;
    this.mergedFrom       = null; // Tracks tiles that merged together

    this.bomb             = false;
    this.explode          = false;
    this.new              = isNew ? true : false;
    this.oldFrom          = null;
}

Tile.prototype.savePosition = function () {
    this.previousPosition = { x: this.x, y: this.y };
};

Tile.prototype.updatePosition = function (position) {
    this.x = position.x;
    this.y = position.y;
};

Tile.prototype.serialize = function () {
    return {
        position: {
            x: this.x,
            y: this.y
        },
        value: this.value
    };
};
