extends Node

onready var prefab = load('particles/particle-effect.tscn')
onready var spark = load('particles/spark.tres')
onready var fire = load('particles/fire.tres')
onready var collision = load('particles/collision.tres')
onready var explosion = load('particles/explosion.tres')

func spawn(particles: ParticlesMaterial, mesh: Mesh, transform: Transform, amount: int, lifetime: float, velocity = null, spread = 10.0):
    assert(particles)
    assert(mesh)
    assert(transform)
    assert(amount > 0)
    assert(lifetime > 0)

    var instance = prefab.instance() as Particles

    instance.process_material = particles
    instance.draw_passes = 1
    instance.draw_pass_1 = mesh
    instance.transform = transform
    instance.amount = amount
    instance.lifetime = lifetime

    if velocity:
        instance.process_material = instance.process_material.duplicate()
        instance.process_material.direction = velocity.normalized()
        instance.process_material.spread = spread
        instance.process_material.initial_velocity = velocity.length()

    add_child(instance)

func spawnCollisionSparks(transform: Transform, amount: int, velocity = null):
    spawn(collision, spark, transform, amount, .5, velocity)

func spawnExplosion(transform: Transform, velocity = null):
    spawn(explosion, spark, transform, 20, 1.2, velocity, 60)
    spawn(explosion, fire, transform, 16, 1.2, velocity, 60)

