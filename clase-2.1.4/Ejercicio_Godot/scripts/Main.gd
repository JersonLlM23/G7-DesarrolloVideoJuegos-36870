extends Node2D

const PlayerScript = preload("res://scripts/Player.gd")
const BG := Color("#080D17")
const PANEL := Color("#0E192B")
const CARD := Color("#14243A")
const BORDER := Color("#293D58")
const WHITE := Color("#F3F7FC")
const MUTED := Color("#91A2BA")
const AQUA := Color("#42D6C5")

var root_ui: Control
var player: CharacterBody2D
var page := "demo"
var status_label: Label
var position_label: Label
var target_label: Label
var target_marker: Label
var challenge_count := 0
var challenge_active := false
var target_position := Vector2(850, 410)

func _ready() -> void:
    _create_interface()
    player = PlayerScript.new()
    root_ui.add_child(player)
    player.z_index = 20
    _show_page("demo")

func _process(_delta: float) -> void:
    if not is_instance_valid(player):
        return
    position_label.text = "POSICIÓN  %04d / %04d" % [int(player.position.x), int(player.position.y)]
    if challenge_active and page == "reto":
        if player.position.distance_to(target_position) < 38:
            challenge_count += 1
            if challenge_count >= 3:
                challenge_active = false
                target_marker.visible = false
                target_label.text = "¡RETO COMPLETADO!  Has usado las acciones para llegar a 3 objetivos."
            else:
                _move_target()
                target_label.text = "OBJETIVOS: %d / 3   •   Busca el siguiente círculo" % challenge_count
    if page == "demo":
        if Input.get_vector("move_left", "move_right", "move_up", "move_down").length() > 0.05:
            status_label.text = "ENTRADA DETECTADA  •  PERSONAJE EN MOVIMIENTO"
            status_label.add_theme_color_override("font_color", AQUA)
        else:
            status_label.text = "EN ESPERA  •  PRUEBA WASD, FLECHAS O EL MANDO"
            status_label.add_theme_color_override("font_color", MUTED)

func _create_interface() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    root_ui = Control.new()
    root_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layer.add_child(root_ui)
    _rect(root_ui, Vector2.ZERO, Vector2(1152, 720), BG, BG, 0)

    _label(root_ui, "GRUPO 07  /  DESARROLLO DE VIDEOJUEGOS", Vector2(44, 20), Vector2(600, 20), 10, AQUA, true)
    _label(root_ui, "INPUT MAP", Vector2(42, 43), Vector2(500, 48), 32, WHITE, true)
    _label(root_ui, "CLASE INTERACTIVA  •  ACCIONES DE ENTRADA Y CONTROL", Vector2(46, 91), Vector2(600, 20), 11, MUTED)
    _rect(root_ui, Vector2(940, 42), Vector2(168, 38), Color("#102B35"), Color("#245D61"), 18)
    _label(root_ui, "GODOT 4  •  GRUPO 07", Vector2(949, 51), Vector2(150, 20), 10, AQUA, true, HORIZONTAL_ALIGNMENT_CENTER)

    _button(root_ui, "DEMOSTRACIÓN", Vector2(42, 128), Vector2(190, 42), "demo")
    _button(root_ui, "APRENDE", Vector2(242, 128), Vector2(160, 42), "aprende")
    _button(root_ui, "RETO", Vector2(412, 128), Vector2(130, 42), "reto")

    var frame := _panel(root_ui, Vector2(42, 184), Vector2(1068, 480), PANEL, BORDER, 20)
    _label(frame, "LABORATORIO DE ENTRADA", Vector2(24, 16), Vector2(360, 22), 12, MUTED, true)
    status_label = _label(frame, "EN ESPERA  •  PRUEBA WASD, FLECHAS O EL MANDO", Vector2(24, 435), Vector2(700, 22), 11, MUTED, true)
    position_label = _label(frame, "POSICIÓN 0576 / 0410", Vector2(790, 435), Vector2(245, 22), 10, MUTED, false, HORIZONTAL_ALIGNMENT_RIGHT)

    # Elementos de la demostración
    var keys = [["01  IZQUIERDA", "A   /   ←"], ["02  DERECHA", "D   /   →"], ["03  ARRIBA", "W   /   ↑"], ["04  ABAJO", "S   /   ↓"]]
    for i in range(4):
        var x := 24 + i * 255
        var card := _panel(frame, Vector2(x, 56), Vector2(235, 82), CARD, BORDER, 12)
        _label(card, keys[i][0], Vector2(14, 10), Vector2(205, 18), 10, MUTED, true)
        _label(card, keys[i][1], Vector2(14, 34), Vector2(205, 32), 21, WHITE, true)
    _rect(frame, Vector2(834, 20), Vector2(208, 28), Color("#102B35"), Color("#245D61"), 12)
    _label(frame, "ZONA MUERTA  0.20", Vector2(840, 26), Vector2(195, 16), 10, AQUA, true, HORIZONTAL_ALIGNMENT_CENTER)
    _label(frame, "MUEVE EL PERSONAJE EN LAS CUATRO DIRECCIONES", Vector2(280, 280), Vector2(500, 24), 12, Color("#607590"), true, HORIZONTAL_ALIGNMENT_CENTER)

    # Paneles informativos
    var learn := _panel(root_ui, Vector2(42, 184), Vector2(1068, 480), PANEL, BORDER, 20)
    learn.name = "LearnPage"
    _label(learn, "¿QUÉ ES INPUT MAP?", Vector2(28, 26), Vector2(500, 34), 22, WHITE, true)
    _label(learn, "Es una herramienta de Godot que permite crear acciones con nombres.\nEl juego responde a la acción, no a una tecla específica.", Vector2(30, 72), Vector2(970, 52), 14, MUTED)
    _info_card(learn, Vector2(28, 150), "1. CREAR ACCIONES", "Proyecto > Ajustes del proyecto > Mapa de entrada.\nAgrega move_left, move_right, move_up y move_down.")
    _info_card(learn, Vector2(548, 150), "2. ASIGNAR EVENTOS", "A cada acción puedes asignarle varias entradas:\nteclas, botones del mando o movimiento del joystick.")
    _info_card(learn, Vector2(28, 278), "3. ZONA MUERTA", "El valor 0.20 evita detectar pequeños movimientos\naccidentales del joystick cuando está en reposo.")
    _info_card(learn, Vector2(548, 278), "4. LEER EN EL CÓDIGO", "Input.get_vector(\"move_left\", \"move_right\",\n\"move_up\", \"move_down\") obtiene la dirección.")

    var challenge := _panel(root_ui, Vector2(42, 184), Vector2(1068, 480), PANEL, BORDER, 20)
    challenge.name = "ChallengePage"
    _label(challenge, "RETO: DOMINA EL MOVIMIENTO", Vector2(28, 24), Vector2(700, 34), 22, WHITE, true)
    _label(challenge, "Demuestra que comprendiste Input Map. Usa las acciones configuradas para alcanzar los tres objetivos.", Vector2(30, 66), Vector2(980, 28), 13, MUTED)
    _rect(challenge, Vector2(28, 116), Vector2(1010, 1), BORDER, BORDER, 0)
    _label(challenge, "OBJETIVO", Vector2(32, 140), Vector2(200, 22), 11, AQUA, true)
    target_label = _label(challenge, "Pulsa INICIAR RETO y recoge los 3 círculos turquesa.", Vector2(32, 168), Vector2(900, 30), 14, WHITE, true)
    target_marker = _label(challenge, "✦", Vector2(target_position.x - 15, target_position.y - 15) - Vector2(42,184), Vector2(34,34), 28, AQUA, true, HORIZONTAL_ALIGNMENT_CENTER)
    target_marker.visible = false
    var start_btn := Button.new()
    start_btn.text = "INICIAR RETO"
    start_btn.position = Vector2(32, 230)
    start_btn.size = Vector2(190, 46)
    _style_button(start_btn, true)
    start_btn.pressed.connect(_start_challenge)
    challenge.add_child(start_btn)
    _label(challenge, "PISTA: SHIFT IZQUIERDO activa SPRINT.\nTambién puedes usar el botón A del mando.\n\nAcciones: move_left, move_right, move_up, move_down y sprint.", Vector2(32, 300), Vector2(700, 100), 12, MUTED)

    _label(root_ui, "OBJETIVO: 4 ACCIONES  •  TECLADO Y MANDO  •  ZONA MUERTA CONFIGURADA: 0.20", Vector2(44, 682), Vector2(950, 18), 10, Color("#687A94"))

func _show_page(value: String) -> void:
    page = value
    var learn = root_ui.find_child("LearnPage", true, false)
    var challenge = root_ui.find_child("ChallengePage", true, false)
    # El panel de demostración es el primer panel grande sin nombre específico.
    for child in root_ui.get_children():
        if child is Panel and child.position == Vector2(42, 184):
            child.visible = value == "demo"
    learn.visible = value == "aprende"
    challenge.visible = value == "reto"
    if is_instance_valid(player):
        player.visible = value != "aprende"
    if is_instance_valid(target_marker):
        target_marker.visible = value == "reto" and challenge_active
    status_label.visible = value == "demo"
    position_label.visible = value != "aprende"

func _button(parent: Control, caption: String, pos: Vector2, size: Vector2, page_name: String) -> void:
    var b := Button.new()
    b.text = caption
    b.position = pos
    b.size = size
    _style_button(b, false)
    b.pressed.connect(_show_page.bind(page_name))
    parent.add_child(b)

func _style_button(b: Button, primary: bool) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = AQUA if primary else Color("#14243A")
    normal.border_color = AQUA if primary else BORDER
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(10)
    b.add_theme_stylebox_override("normal", normal)
    var hover := normal.duplicate()
    hover.bg_color = Color("#2BAF9F") if primary else Color("#1B304A")
    b.add_theme_stylebox_override("hover", hover)
    b.add_theme_color_override("font_color", Color("#07151B") if primary else WHITE)
    b.add_theme_font_size_override("font_size", 11)

func _start_challenge() -> void:
    challenge_count = 0
    challenge_active = true
    player.position = Vector2(576, 410)
    _move_target()
    target_label.text = "OBJETIVOS: 0 / 3   •   ¡Muévete hasta el círculo!"
    target_marker.visible = true

func _move_target() -> void:
    var spots = [Vector2(900, 420), Vector2(270, 520), Vector2(850, 270)]
    target_position = spots[challenge_count % spots.size()]
    target_marker.position = target_position - Vector2(42, 184) - Vector2(15, 15)

func _info_card(parent: Control, pos: Vector2, heading: String, body: String) -> void:
    var card := _panel(parent, pos, Vector2(490, 108), CARD, BORDER, 12)
    _label(card, heading, Vector2(16, 14), Vector2(440, 20), 11, AQUA, true)
    _label(card, body, Vector2(16, 42), Vector2(455, 55), 12, MUTED)

func _label(parent: Control, value: String, pos: Vector2, size: Vector2, font_size: int, color: Color, bold := false, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
    var label := Label.new()
    label.text = value
    label.position = pos
    label.size = size
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.horizontal_alignment = align
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    if bold:
        label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.15))
    parent.add_child(label)
    return label

func _rect(parent: Control, pos: Vector2, size: Vector2, color: Color, border: Color, radius: int) -> Panel:
    var panel := Panel.new()
    panel.position = pos
    panel.size = size
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.border_color = border
    style.set_border_width_all(1 if radius > 0 else 0)
    style.set_corner_radius_all(radius)
    panel.add_theme_stylebox_override("panel", style)
    parent.add_child(panel)
    return panel

func _panel(parent: Control, pos: Vector2, size: Vector2, color: Color, border: Color, radius: int) -> Panel:
    return _rect(parent, pos, size, color, border, radius)
