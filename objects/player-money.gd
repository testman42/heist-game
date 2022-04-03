extends Spatial


export(ParticlesMaterial) var particlesMaterial
export(Mesh) var particlesMesh


func _on_player_player_collision(amount):
    amount = abs(amount)
    if amount < 4:
        return

    ParticleEffect.spawn(particlesMaterial, particlesMesh, global_transform, round(rand_range(4, 4 + amount / 10)), 1)