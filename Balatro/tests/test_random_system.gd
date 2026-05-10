extends TestSuite

var random_system: RandomSystem

func init_random_system():
	random_system = RandomSystem.new()
	add_child(random_system)

func test_deterministic_seed():
	init_random_system()
	
	random_system.set_seed(12345)
	var values1: Array = []
	for i in range(10):
		values1.append(random_system.randi())
	
	random_system.set_seed(12345)
	var values2: Array = []
	for i in range(10):
		values2.append(random_system.randi())
	
	for i in range(10):
		assert_eq(values1[i], values2[i])

func test_randf_range():
	init_random_system()
	
	random_system.set_seed(42)
	var value = random_system.randf_range(10.0, 20.0)
	assert_le(value, 20.0)
	assert_ge(value, 10.0)

func test_randf_range_equivalence():
	init_random_system()
	
	random_system.set_seed(100)
	var val1 = random_system.randf_range(0.0, 1.0)
	var val2 = random_system.randf_range(0.0, 1.0)
	assert_ne(val1, val2)

func test_choose():
	init_random_system()
	random_system.set_seed(7)
	
	var items = ["a", "b", "c", "d"]
	var chosen = random_system.choose(items)
	assert_true(items.has(chosen))

func test_choose_from_empty():
	init_random_system()
	var result = random_system.choose([])
	assert_eq(result, null)

func test_weighted_selection():
	init_random_system()
	random_system.set_seed(100)
	
	var weights: Array[float] = [0.0, 1.0, 0.0]
	var result = random_system.choose_weighted(weights)
	assert_eq(result, 1)

func test_weighted_selection_random():
	init_random_system()
	random_system.set_seed(42)
	
	var weights: Array[float] = [1.0, 1.0, 1.0]
	var results: Array = []
	for i in range(30):
		results.append(random_system.choose_weighted(weights))
	
	var counts = [0, 0, 0]
	for r in results:
		counts[r] += 1
	
	assert_true(counts[0] > 0 and counts[1] > 0 and counts[2] > 0)

func test_shuffle():
	init_random_system()
	random_system.set_seed(999)
	
	var original = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
	var shuffled = random_system.shuffle_array(original)
	
	assert_eq(shuffled.size(), original.size())
	assert_true(_is_permutation(original, shuffled))

func _is_permutation(a: Array, b: Array) -> bool:
	var a_sorted = a.duplicate()
	var b_sorted = b.duplicate()
	a_sorted.sort()
	b_sorted.sort()
	
	for i in range(a_sorted.size()):
		if a_sorted[i] != b_sorted[i]:
			return false
	return true

func test_weighted_pool():
	init_random_system()
	
	var pool_id = "test_items"
	var items: Array[Dictionary] = [
		{"id": "item1", "weight": 3},
		{"id": "item2", "weight": 2},
		{"id": "item3", "weight": 1}
	]
	
	random_system.create_weighted_pool(pool_id, items)
	
	var drawn: Array = []
	for i in range(6):
		var item = random_system.get_from_weighted_pool(pool_id)
		if item.has("id"):
			drawn.append(item["id"])
	
	assert_true(drawn.size() <= 3)

func test_call_count():
	init_random_system()
	
	assert_eq(random_system.get_call_count(), 0)
	random_system.randi()
	assert_eq(random_system.get_call_count(), 1)
	random_system.randf()
	assert_eq(random_system.get_call_count(), 2)
