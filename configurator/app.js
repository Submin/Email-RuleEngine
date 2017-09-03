var RuleEngine = new Object();

RuleEngine.nodes = [];
RuleEngine.node_id = 0;

RuleEngine.start_node = {
    id: 0,
    name: 'start_node',
    title: 'Start',
    width: 80,
    height: 60,
    x: 10,
    y: 10,
    inputs: [],
    outputs: ['O']
};

RuleEngine.start = function() {
    RuleEngine.editor = Ned.create("#svg");

    RuleEngine.editor.screenToWorld = function(pos) {
        var rect = this.svg.getBoundingClientRect();

        return { 
            x: (pos.x - rect.left), 
            y: (pos.y - rect.top)
        };
    };

    // Base events
//    RuleEngine.editor.svg.addEventListener("keyup", (e) => {
    document.addEventListener("keyup", (e) => {
        if (e.code == "Delete") RuleEngine.del_nodes;
    });

    $$('add_node').addEventListener("click", (e) => {
        var wrapper = $$i({ 
            create: 'div',
            attribute: {
                id:'modal-wrapper',
                class:'modal-wrapper'
            },
            insert: $$().body
        }); 

        $$(wrapper, $$('tpl-node-create-dialog').$$html());

        $$('create_node').addEventListener("click", (e) => {
            var name = $$("node-name").value;
            var title = $$("node-title").value;
            if (name) {
                title = title || name;
                $$().body.removeChild(wrapper);

                RuleEngine.add_node({ title: title, name: name });
            }
        });
    });

    document.getElementById('del_node').addEventListener("click", (e) => {
        RuleEngine.del_nodes();
    });

    RuleEngine.add_node(RuleEngine.start_node);
//    RuleEngine.add_pair(0);
};

RuleEngine.add_node = function(node) {
    var n = RuleEngine.editor.createNode(node.title);

    n.id = RuleEngine.node_id++;
    n.title = node.title;
    n.name = node.name;
/*
    var index;
    var node = RuleEngine.nodes.find( function(item, i, a) {
        if (item.id == id) {
            index = i;
            return true;
        } else {
            return false;
        }
    });
*/

    n.position = {
        x: node.x ? node.x : 100,
        y: node.y ? node.y : 100
    };

    n.size = {
        width: node.width ? node.width : 250,
        height: node.height ? node.height : 100
    };

    node.inputs = n.id > 0 ? ['I'] : [];
    node.outputs = node.outputs ? node.outputs : [];
    node.inputs.forEach(function(item, i, a) {
        n.addInput(item);
    });
    node.outputs.forEach(function(item, i, a) {
        n.addOutput(item);
    });

    if (n.id > 0) {
        var wrapper = $$i({ create: 'div', attribute: { class: 'right' }, insert: n.eForeign });
        var button = $$i({ create: 'button', attribute: { class:'control_btn' }, insert: wrapper }).$$('+');

        button.addEventListener("click", (e) => {
            RuleEngine.add_pair(n.id);
        });
    }

    RuleEngine.nodes.push(n);
};

RuleEngine.del_nodes = function() {
    for(let node of this.editor.selectedNodes) {
        if (node.id == 0) continue;
        node.destroy();
    }
    this.editor.selectedNodes = [];
};

RuleEngine.add_pair = function(id) {
    var wrapper = $$i({ 
        create: 'div', attribute: { id: 'modal-wrapper', class: 'modal-wrapper' }, insert: $$().body
    }); 

        $$(wrapper, $$('tpl-node-create-dialog').$$html());

    var prop_dialog = $$i({
        create: 'div', attribute: { class: 'dialog node-properties-dialog' }, insert: wrapper
    });

    var heaser = $$i({
        create: 'div', attribute: { class: 'header' }, insert: prop_dialog
    }).$$('Node properties ID: '+node.id+', Name: '+node.name+', Title: '+node.title);
    var condition = $$i({
        create: 'div', attribute: { class: 'left' }, insert: prop_dialog
    });
    var action = $$i({
        create: 'div', attribute: { class: 'right' }, insert: prop_dialog
    });
};

RuleEngine.set_pair = function(id) {
};
