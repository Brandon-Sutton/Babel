class_name GuideProp
## EQV-002/003: reads attach points out of animation frames for visible equipment.
##
## Elam is animated holding a key-green guide rod in his right hand (ART_BIBLE §6.3).
## For every frame this finds the rod, fits its axis, finds the grip (where the fist
## covers the rod) and the angle toward the blade end, then erases the rod: rod pixels
## over the body are filled from the surrounding body pixels, the rest become
## transparent. A key-green swing smear (many more key pixels than the rod) is cut out
## as a separate grey mask so it can be tinted per weapon. Body points (head, neck,
## chest, belt, ankles) are measured from the silhouette of any frame.

## Frames with more key pixels than SMEAR_FACTOR x the animation's median are smears.
const SMEAR_FACTOR: float = 2.2
## Detached clusters of at most SPECK_MAX pixels within SPECK_REACH of the erased rod
## are leftovers of it, not body.
const SPECK_MAX: int = 7
const SPECK_REACH: int = 3
## A frame with at least this many magenta pixels shows a (magenta) swing smear.
const MAGENTA_SMEAR_MIN: int = 40
## How far (px) to look across a key pixel for body pixels on both sides.
const FILL_REACH: int = 24
## Skin along the rod with a gap wider than this (px) belongs to two separate fists.
const FIST_GAP: float = 4.0
## Max distance (px) from the rod axis for a skin pixel to count as the gripping fist.
const GRIP_DISTANCE: float = 3.5
## The far (left) hand, from the chest point: at the torso's front edge, a little low,
## so a shield strapped to it shows half its face past the body and stays put while
## the right hand swings.
const FAR_HAND_FROM_CHEST: Vector2 = Vector2(4, 10)
## Height of an ankle above the sole, px.
const ANKLE_HEIGHT: int = 10


## What one frame yields.
class Extraction:
	## The frame with the rod and smear removed.
	var body: Image
	## Grey mask of the key-green smear (transparent where there is none).
	var smear: Image
	var key_count: int = 0
	var has_rod: bool = false
	var is_smear: bool = false
	## Grip in frame pixels, and the blade direction in degrees (0 = right, y down).
	var grip: Vector2 = Vector2.ZERO
	var angle: float = 0.0


## True for the guide prop's key green (and its darker, anti-aliased edge).
static func is_key(c: Color) -> bool:
	return c.a8 > 0 and c.g8 > 50 and c.g8 > c.r8 + 15 and c.g8 > c.b8 + 15


static func is_skin(c: Color) -> bool:
	return c.a8 > 0 and c.r8 > 150 and c.r8 > c.b8 + 50 and c.g8 > 70


## Extracts every frame of one animation. Smear frames and frames where the rod is
## hidden take their grip and angle from the nearest frames that show the rod.
static func extract_animation(frames: Array[Image]) -> Array[Extraction]:
	var results: Array[Extraction] = []
	var counts: Array[int] = []
	for frame: Image in frames:
		var key: Array[Vector2i] = _key_pixels(frame)
		counts.append(key.size())
	var sorted_counts: Array[int] = counts.duplicate()
	sorted_counts.sort()
	var median: int = sorted_counts[sorted_counts.size() / 2] if not sorted_counts.is_empty() else 0
	for i: int in frames.size():
		var smear: bool = median > 0 and counts[i] > maxi(200, roundi(median * SMEAR_FACTOR))
		results.append(_extract(frames[i], smear))
	_fill_gaps(results)
	return results


static func _extract(frame: Image, smear: bool) -> Extraction:
	var result: Extraction = Extraction.new()
	var key: Array[Vector2i] = _key_pixels(frame)
	# PixMiniMax sometimes paints the swing smear in magenta instead of key green.
	var magenta: Array[Vector2i] = _magenta_pixels(frame)
	result.key_count = key.size()
	result.is_smear = smear or magenta.size() >= MAGENTA_SMEAR_MIN
	if not smear and key.size() >= 6:
		_fit_rod(frame, key, result)
	var smear_pixels: Array[Vector2i] = []
	if smear:
		smear_pixels.append_array(key)
	if result.is_smear:
		smear_pixels.append_array(magenta)
	var erased: Array[Vector2i] = key.duplicate()
	erased.append_array(magenta)
	result.body = _erase(frame, erased)
	result.smear = Image.create_empty(frame.get_width(), frame.get_height(), false, Image.FORMAT_RGBA8)
	for p: Vector2i in smear_pixels:
		var c: Color = frame.get_pixelv(p)
		# The bright core reads as full brightness, the dark edge dimmer, so the weapon's
		# slash colour comes through at full strength.
		var lightness: float = clampf(0.6 + maxf(c.g, (c.r + c.b) * 0.5) * 0.4 + minf(c.r, c.b) * 0.5, 0.0, 1.0)
		result.smear.set_pixelv(p, Color(lightness, lightness, lightness, c.a))
	return result


## Saturated magenta or pink: a smear the model painted in the wrong key colour. Elam's
## palette has none (his crimson lining is low in blue, the violet trim is dark).
static func is_magenta(c: Color) -> bool:
	return c.a8 > 0 and c.r8 > 150 and c.b8 > 150 and c.g8 < c.r8 - 60 and c.g8 < c.b8 - 60


static func _magenta_pixels(frame: Image) -> Array[Vector2i]:
	var pixels: Array[Vector2i] = []
	for y: int in frame.get_height():
		for x: int in frame.get_width():
			if is_magenta(frame.get_pixel(x, y)):
				pixels.append(Vector2i(x, y))
	return pixels


## Key-green pixels, plus near-white pixels that key green bounds on both sides along a
## row or column (the bright core of a swing smear). A plate highlight that merely
## touches the rod is bounded on one side only and stays.
static func _key_pixels(frame: Image) -> Array[Vector2i]:
	var key: Array[Vector2i] = []
	var is_key_px: Dictionary[Vector2i, bool] = {}
	for y: int in frame.get_height():
		for x: int in frame.get_width():
			if is_key(frame.get_pixel(x, y)):
				key.append(Vector2i(x, y))
				is_key_px[Vector2i(x, y)] = true
	var cores: Array[Vector2i] = []
	for y: int in frame.get_height():
		for x: int in frame.get_width():
			var p: Vector2i = Vector2i(x, y)
			if _is_whiteish(frame.get_pixelv(p)) and (_bounded(frame, is_key_px, p, Vector2i.RIGHT)
					or _bounded(frame, is_key_px, p, Vector2i.DOWN)):
				cores.append(p)
	key.append_array(cores)
	return key


static func _is_whiteish(c: Color) -> bool:
	return c.a8 > 0 and c.r8 >= 190 and c.g8 >= 200 and c.b8 >= 190 and c.g8 >= c.r8 - 5


## True if walking from [param p] both ways along [param axis] through near-white
## pixels ends on key green each time.
static func _bounded(frame: Image, is_key_px: Dictionary[Vector2i, bool], p: Vector2i, axis: Vector2i) -> bool:
	for dir: Vector2i in [axis, -axis]:
		var q: Vector2i = p + dir
		while (q.x >= 0 and q.y >= 0 and q.x < frame.get_width() and q.y < frame.get_height()
				and not is_key_px.has(q) and _is_whiteish(frame.get_pixelv(q))):
			q += dir
		if not is_key_px.has(q):
			return false
	return true


## Principal axis of the rod; grip = mean projection of the fist's skin pixels.
static func _fit_rod(frame: Image, key: Array[Vector2i], result: Extraction) -> void:
	var mean: Vector2 = Vector2.ZERO
	for p: Vector2i in key:
		mean += Vector2(p)
	mean /= key.size()
	var sxx: float = 0.0
	var syy: float = 0.0
	var sxy: float = 0.0
	for p: Vector2i in key:
		var d: Vector2 = Vector2(p) - mean
		sxx += d.x * d.x
		syy += d.y * d.y
		sxy += d.x * d.y
	var axis: Vector2 = Vector2.from_angle(0.5 * atan2(2.0 * sxy, sxx - syy))
	var t_min: float = INF
	var t_max: float = -INF
	for p: Vector2i in key:
		var t: float = (Vector2(p) - mean).dot(axis)
		t_min = minf(t_min, t)
		t_max = maxf(t_max, t)
	var hand_ts: Array[float] = []
	var normal: Vector2 = Vector2(-axis.y, axis.x)
	for y: int in frame.get_height():
		for x: int in frame.get_width():
			if not is_skin(frame.get_pixel(x, y)):
				continue
			var d: Vector2 = Vector2(x, y) - mean
			var t: float = d.dot(axis)
			if absf(d.dot(normal)) <= GRIP_DISTANCE and t >= t_min - 4.0 and t <= t_max + 4.0:
				hand_ts.append(t)
	if hand_ts.is_empty():
		return
	# The blade points from the hands toward the rod's longer side.
	var t_hands: float = _mean(hand_ts)
	var blade_positive: bool = absf(t_max - t_hands) >= absf(t_min - t_hands)
	# Two fists apart on the rod (a wide two-handed grip): the grip is the rear fist,
	# the one nearer the butt, so the weapon's grip sits in that hand and the blade runs
	# forward through the other.
	var fists: Array[Array] = _fist_clusters(hand_ts)
	var rear: Array = fists[0] if blade_positive else fists[-1]
	result.grip = mean + axis * _mean(rear)
	if not blade_positive:
		axis = -axis
	result.angle = rad_to_deg(axis.angle())
	result.has_rod = true


## Groups positions along the rod into fists: a gap of more than FIST_GAP px starts a
## new one. Sorted from the rod's negative end.
static func _fist_clusters(ts: Array[float]) -> Array[Array]:
	var sorted_ts: Array[float] = ts.duplicate()
	sorted_ts.sort()
	var clusters: Array[Array] = [[sorted_ts[0]]]
	for i: int in range(1, sorted_ts.size()):
		if sorted_ts[i] - sorted_ts[i - 1] > FIST_GAP:
			clusters.append([])
		clusters[-1].append(sorted_ts[i])
	return clusters


static func _mean(values: Array) -> float:
	var total: float = 0.0
	for value: float in values:
		total += value
	return total / values.size()


## Removes key pixels: filled from body pixels found on both sides, else transparent.
static func _erase(frame: Image, key: Array[Vector2i]) -> Image:
	var body: Image = frame.duplicate() as Image
	var is_key_px: Dictionary[Vector2i, bool] = {}
	for p: Vector2i in key:
		is_key_px[p] = true
	var size: Vector2i = frame.get_size()
	for p: Vector2i in key:
		var hits: Dictionary[Vector2i, Color] = {}
		var nearest: int = FILL_REACH + 1
		var fill: Color = Color(0, 0, 0, 0)
		for dir: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]:
			for step: int in range(1, FILL_REACH + 1):
				var q: Vector2i = p + dir * step
				if q.x < 0 or q.y < 0 or q.x >= size.x or q.y >= size.y:
					break
				if is_key_px.has(q):
					continue
				var c: Color = frame.get_pixelv(q)
				if c.a8 > 0:
					hits[dir] = c
					if step < nearest:
						nearest = step
						fill = c
				break
		var enclosed: bool = (hits.has(Vector2i.RIGHT) and hits.has(Vector2i.LEFT)) \
				or (hits.has(Vector2i.DOWN) and hits.has(Vector2i.UP))
		body.set_pixelv(p, fill if enclosed else Color(0, 0, 0, 0))
	_remove_specks(body, is_key_px)
	return body


## Clears tiny detached clusters left next to where the rod was: anti-aliased pixels the
## model drew at the rod's tip in a colour that isn't key green.
static func _remove_specks(body: Image, erased: Dictionary[Vector2i, bool]) -> void:
	var size: Vector2i = body.get_size()
	var seen: Dictionary[Vector2i, bool] = {}
	for p: Vector2i in erased:
		for dy: int in range(-SPECK_REACH, SPECK_REACH + 1):
			for dx: int in range(-SPECK_REACH, SPECK_REACH + 1):
				var start: Vector2i = p + Vector2i(dx, dy)
				if start.x < 0 or start.y < 0 or start.x >= size.x or start.y >= size.y \
						or seen.has(start) or body.get_pixelv(start).a8 == 0:
					continue
				var cluster: Array[Vector2i] = []
				var stack: Array[Vector2i] = [start]
				seen[start] = true
				while not stack.is_empty() and cluster.size() <= SPECK_MAX:
					var q: Vector2i = stack.pop_back()
					cluster.append(q)
					for oy: int in range(-1, 2):
						for ox: int in range(-1, 2):
							var n: Vector2i = q + Vector2i(ox, oy)
							if n.x >= 0 and n.y >= 0 and n.x < size.x and n.y < size.y \
									and not seen.has(n) and body.get_pixelv(n).a8 > 0:
								seen[n] = true
								stack.append(n)
				if cluster.size() <= SPECK_MAX and stack.is_empty():
					for q: Vector2i in cluster:
						body.set_pixelv(q, Color(0, 0, 0, 0))


## Smear frames and frames without a visible rod borrow the grip from neighbours.
static func _fill_gaps(results: Array[Extraction]) -> void:
	for i: int in results.size():
		if results[i].has_rod:
			continue
		var before: int = i - 1
		while before >= 0 and not results[before].has_rod:
			before -= 1
		var after: int = i + 1
		while after < results.size() and not results[after].has_rod:
			after += 1
		if before >= 0 and after < results.size():
			var t: float = float(i - before) / float(after - before)
			results[i].grip = results[before].grip.lerp(results[after].grip, t)
			results[i].angle = rad_to_deg(lerp_angle(deg_to_rad(results[before].angle), deg_to_rad(results[after].angle), t))
		elif before >= 0:
			results[i].grip = results[before].grip
			results[i].angle = results[before].angle
		elif after < results.size():
			results[i].grip = results[after].grip
			results[i].angle = results[after].angle


## Body attach points of one frame (body art without the rod), relative to [param pivot]
## (the feet). Keys: head, neck, chest, belt, hand_l, ankle_f, ankle_b. Facing right.
static func body_points(body: Image, pivot: Vector2i) -> Dictionary[StringName, Vector2]:
	var points: Dictionary[StringName, Vector2] = {}
	var used: Rect2i = body.get_used_rect()
	if not used.has_area():
		return points
	var top: int = used.position.y
	var bottom: int = used.end.y - 1
	# Skip stray pixels above the head: the first row with at least two opaque pixels.
	while top < bottom and _row_count(body, top) < 2:
		top += 1
	var height: float = float(bottom - top + 1)
	var head_x: float = _row_centre(body, top, top + 10)
	points[&"head"] = Vector2(head_x, top + 6)
	points[&"neck"] = Vector2(head_x - 1.0, top + roundi(height * 0.18))
	var chest_y: int = top + roundi(height * 0.32)
	points[&"chest"] = Vector2(_run_end(body, chest_y, roundi(head_x)) - 4, chest_y)
	points[&"hand_l"] = points[&"chest"] + FAR_HAND_FROM_CHEST
	var belt_y: int = top + roundi(height * 0.5)
	points[&"belt"] = Vector2(_run_centre(body, belt_y, roundi(head_x)), belt_y)
	var soles: Array[Vector2] = _sole_clusters(body, bottom)
	points[&"ankle_f"] = Vector2(soles[-1].x, soles[-1].y - ANKLE_HEIGHT)
	points[&"ankle_b"] = Vector2(soles[0].x, soles[0].y - ANKLE_HEIGHT)
	for key: StringName in points:
		points[key] -= Vector2(pivot)
	return points


static func _row_count(image: Image, y: int) -> int:
	var count: int = 0
	for x: int in image.get_width():
		if image.get_pixel(x, y).a8 > 0:
			count += 1
	return count


static func _row_centre(image: Image, from_y: int, to_y: int) -> float:
	var sum: float = 0.0
	var count: int = 0
	for y: int in range(from_y, mini(to_y, image.get_height())):
		for x: int in image.get_width():
			if image.get_pixel(x, y).a8 > 0:
				sum += x
				count += 1
	return sum / count if count > 0 else image.get_width() / 2.0


## Last opaque x of the run of opaque pixels on row [param y] that contains [param x].
static func _run_end(image: Image, y: int, x: int) -> int:
	var end: int = clampi(x, 0, image.get_width() - 1)
	while end + 1 < image.get_width() and image.get_pixel(end + 1, y).a8 > 0:
		end += 1
	return end


static func _run_centre(image: Image, y: int, x: int) -> float:
	var start: int = clampi(x, 0, image.get_width() - 1)
	while start - 1 >= 0 and image.get_pixel(start - 1, y).a8 > 0:
		start -= 1
	return (start + _run_end(image, y, x)) / 2.0


## Centres of the opaque clusters on the lowest rows (the soles), left to right.
static func _sole_clusters(image: Image, bottom: int) -> Array[Vector2]:
	var columns: Array[int] = []
	for x: int in image.get_width():
		for y: int in range(maxi(bottom - 2, 0), bottom + 1):
			if image.get_pixel(x, y).a8 > 0:
				columns.append(x)
				break
	var clusters: Array[Vector2] = []
	var start: int = -1
	var last: int = -10
	for x: int in columns:
		if x - last > 2:
			if start >= 0:
				clusters.append(Vector2((start + last) / 2.0, bottom))
			start = x
		last = x
	if start >= 0:
		clusters.append(Vector2((start + last) / 2.0, bottom))
	if clusters.is_empty():
		clusters.append(Vector2(image.get_width() / 2.0, bottom))
	return clusters
