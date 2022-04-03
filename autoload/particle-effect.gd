extends Node

onready var prefab = load('particles/particle-effect.tscn')

func spawn(particles: ParticlesMaterial, mesh: Mesh, transform: Transform):
    assert(particles)
    assert(mesh)
    assert(transform)

    var instance = prefab.instance() as Particles
    instance.process_material = particles
    instance.draw_passes = 1
    instance.draw_pass_1 = mesh
    instance.transform = transform

    add_child(instance)

