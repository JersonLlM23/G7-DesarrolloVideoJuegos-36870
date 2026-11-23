extends CharacterBody2D

@export var speed: float = 250.0
@export var sprint_speed: float = 420.0
var area := Rect2(42, 118, 1068, 550)

func _ready() -> void:
    position = Vector2(576, 410)

func _physics_process(_delta: float) -> void:
    # El código consulta acciones, no teclas físicas.
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var current_speed := speed
    if Input.is_action_pressed("sprint"):
        current_speed = sprint_speed
    velocity = direction * current_speed
    move_and_slide()
    position.x = clampf(position.x, area.position.x + 24, area.end.x - 24)
    position.y = clampf(position.y, area.position.y + 24, area.end.y - 24)
    queue_redraw()

func _draw() -> void:
    draw_circle(Vector2(0, 6), 25, Color(0, 0, 0, 0.28))
    draw_circle(Vector2.ZERO, 22, Color("#42D6C5"))
    draw_circle(Vector2(-6, -7), 7, Color("#D9FFFA"))
    draw_arc(Vector2.ZERO, 22, 0, TAU, 48, Color("#B7FFF5"), 2.5)
    draw_circle(Vector2(7, 2), 3, Color("#12313C"))
