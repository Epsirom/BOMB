function HTMLActuator() {
    this.tileContainer    = document.querySelector(".tile-container");
    this.scoreContainer   = document.querySelector(".score-container");
    this.bestContainer    = document.querySelector(".best-container");
    this.messageContainer = document.querySelector(".game-message");
    this.targetNumContainer = document.querySelector(".combine-container");
    this.soundContainer = document.querySelector(".sound-container");

    this.score = 0;
    this.targetNum = 4;
}

HTMLActuator.prototype.actuate = function (grid, metadata) {
    var self = this;

    window.requestAnimationFrame(function () {
        self.clearContainer(self.tileContainer);

        grid.cells.forEach(function (column) {
            column.forEach(function (cell) {
                if (cell) {
                    self.addTile(cell, metadata.targetNum);
                }
            });
        });

        self.updateScore(metadata.score);
        self.updateBestScore(metadata.bestScore);
        self.updateTargetNum(metadata.targetNum);

        if (metadata.terminated) {
            if (metadata.over) {
                self.message(false); // You lose
            } else if (metadata.won) {
                self.message(true); // You win!
            }
        }

    });
};

// Continues the game (both restart and keep playing)
HTMLActuator.prototype.continueGame = function () {
    this.clearMessage();
};

HTMLActuator.prototype.clearContainer = function (container) {
    while (container.firstChild) {
        container.removeChild(container.firstChild);
    }
};

HTMLActuator.prototype.addTile = function (tile, targetNum) {
    if (tile.oldFrom) {
        this.addTile(tile.oldFrom, targetNum);
    }
    var self = this;

    var wrapper   = document.createElement("div");
    var inner     = document.createElement("div");
    var position  = tile.previousPosition || { x: tile.x, y: tile.y };
    var positionClass = this.positionClass(position);

    // We can't use classlist because it somehow glitches when replacing classes
    var classes = ["tile", "tile-" + (tile.bomb&&!tile.new ? targetNum / 2 : tile.value), positionClass];

    if (tile.value > 2048 || targetNum > 2048) classes.push("tile-super");

    inner.classList.add("tile-inner");
    if (tile.bomb) {
        classes.push("tile-bomb");
        if (tile.new) {
            inner.textContent = tile.value;
            classes.push('tile-new');
        } else {
            inner.textContent = "💣";
        }
    }
    if (tile.value < 0) {
        classes.push('tile-wall');
        inner.textContent = "";
    }
    if (tile.explode) {
        classes.push('tile-wall tile-explode');

        if (tile.new) {
            inner.textContent = tile.value;
            classes.push('tile-new');
        }
    }
    if (tile.value > 0) {
        inner.textContent = tile.value;
    }
    if (!(tile.bomb || tile.explode) && tile.value == 0) {
        return;
    }

    this.applyClasses(wrapper, classes);

    if (tile.previousPosition) {
        // Make sure that the tile gets rendered in the previous position first
        window.requestAnimationFrame(function () {
            classes[2] = self.positionClass({ x: tile.x, y: tile.y });
            self.applyClasses(wrapper, classes); // Update the position
        });
    } else if (tile.explode) {
        this.applyClasses(wrapper, classes);
    } else if (tile.mergedFrom) {
        if (!tile.bomb) {
            classes.push("tile-merged");
        }

        this.applyClasses(wrapper, classes);

        // Render the tiles that merged
        tile.mergedFrom.forEach(function (merged) {
            self.addTile(merged, targetNum);
        });
    } else {
        classes.push("tile-new");
        this.applyClasses(wrapper, classes);
    }

    // Add the inner part of the tile to the wrapper
    wrapper.appendChild(inner);

    // Put the tile on the board
    this.tileContainer.appendChild(wrapper);
};

HTMLActuator.prototype.applyClasses = function (element, classes) {
    element.setAttribute("class", classes.join(" "));
};

HTMLActuator.prototype.normalizePosition = function (position) {
    return { x: position.x + 1, y: position.y + 1 };
};

HTMLActuator.prototype.positionClass = function (position) {
    position = this.normalizePosition(position);
    return "tile-position-" + position.x + "-" + position.y;
};

HTMLActuator.prototype.updateScore = function (score) {
    this.clearContainer(this.scoreContainer);

    var difference = score - this.score;
    this.score = score;

    this.scoreContainer.textContent = this.score;

    if (difference > 0) {
        var addition = document.createElement("div");
        addition.classList.add("score-addition");
        addition.textContent = "+" + difference;

        this.scoreContainer.appendChild(addition);
    }
};

HTMLActuator.prototype.updateBestScore = function (bestScore) {
    this.bestContainer.textContent = bestScore;
};

HTMLActuator.prototype.updateTargetNum = function (targetNum) {
    this.clearContainer(this.targetNumContainer);

    this.targetNumContainer.textContent = targetNum;

    var difference = targetNum / this.targetNum;
    this.targetNum = targetNum;
    if (difference > 1) {
        var addition = document.createElement("div");
        addition.classList.add("score-addition");
        addition.textContent = "*" + difference;

        this.targetNumContainer.appendChild(addition);
    }
};

HTMLActuator.prototype.message = function (won) {
    var type    = won ? "game-won" : "game-over";
    var message = won ? "You win!" : "Game over!";

    this.messageContainer.classList.add(type);
    this.messageContainer.getElementsByTagName("p")[0].textContent = message;
};

HTMLActuator.prototype.clearMessage = function () {
    // IE only takes one value to remove at a time.
    this.messageContainer.classList.remove("game-won");
    this.messageContainer.classList.remove("game-over");
};

HTMLActuator.prototype.playBomb = function () {
    this.playSound("bomb.mp3");
};

HTMLActuator.prototype.playWin = function () {
    this.playSound("win.wav");
};

HTMLActuator.prototype.playOver = function () {
    this.playSound("over.wav");
};

HTMLActuator.prototype.playSound = function(sound) {
    var self = this;
    self.soundContainer.innerHTML = '<embed src="../meta/' + sound + '" loop="0" autostart="true" hidden="true"></embed>';
};