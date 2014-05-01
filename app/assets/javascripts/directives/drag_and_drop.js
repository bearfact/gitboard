gitBoard.directive("draggable", function() {
    return function(scope, element) {
        var el;
        el = element[0];
        el.draggable = true;
        el.addEventListener("dragstart", (function(e) {
            e.dataTransfer.effectAllowed = "move";
            e.dataTransfer.setData("Text", this.id);
            this.classList.add("drag");
            return false;
        }), false);
        return el.addEventListener("dragend", (function(e) {
            this.classList.remove("drag");
            return false;
        }), false);
    };
});

gitBoard.directive("droppable", function() {
    return {
        scope: {
            drop: "&drop"
        },
        link: function(scope, element) {
            var el;
            el = element[0];
            el.addEventListener("dragover", (function(e) {
                e.dataTransfer.dropEffect = "move";
                if (e.preventDefault) {
                    e.preventDefault();
                }
                this.classList.add("over");
                return false;
            }), false);
            el.addEventListener("dragenter", (function(e) {
                this.classList.add("over");
                return false;
            }), false);
            el.addEventListener("dragleave", (function(e) {
                this.classList.remove("over");
                return false;
            }), false);
            return el.addEventListener("drop", (function(e) {
                var data, item;
                if (e.preventDefault) {
                    e.preventDefault();
                }
                if (e.stopPropagation) {
                    e.stopPropagation();
                }
                this.classList.remove("over");
                item = document.getElementById(e.dataTransfer.getData("Text"));
                data = $(item).data().$scope.issue;
                data["new_position"] = scope.drop();
                scope.$emit("issueDropEvent", data);
                return false;
            }), false);
        }
    };
});
