extends Node2D
#------------------------------------------------------------------------------
# The enemies travel on a Path2D->PathFollow2D. I'm using the following terms:
# enemy  - is an enemy node Area2D+collision etc
#          its NOT a child of PathFollow2D, it copies the position of PathFollow2D
# rail   - Path2D,        is the path(curve) the enemies will follow
#
#- - - - - - - - - - - - - - - - - - - - -  Path2D Resources

signal sigEnemyWave

#- - - - - - - - - - - - - - - - - - - - -  Path2D Resources
onready var res_Paths  = [  preload("res://paths/Path_01_loopcenter.tscn") , 
							preload("res://paths/Path_02_loopcenter.tscn") , 
							preload("res://paths/Path_03_loopcenter.tscn") ]
#- - - - - - - - - - - - - - - - - - - - -  
var rail
#- - - - - - - - - - - - - - - - - - - - -  Sprite Resources 
onready var res_Enemy  = [  preload("res://Enemies/Enemy_BattleCruiser.tscn") , 
							preload("res://Enemies/Enemy_BattleCruiser.tscn") , 
							preload("res://Enemies/Enemy_BattleCruiser.tscn") ]
#- - - - - - - - - - - - - - - - - - - - -   Resources 
onready var res_floatingtext = preload("res://ScoreBoard/FloatingText.tscn")

#- - - - - - - - - - - - - - - - - - - - -  var's
var fsm:int = 0                                    # state machine state
enum {INIT, WAVE, ENEMIESKILLED, NEWWAVEINTRO, ENDOFLEVEL}

export var enemywaveconfig = {
		railnr     = 0,
		rail_angle = 0,
		mirrorwave = true,
		shiptype   = 0,
		nrEnemies  = 8,
		speed      = 300,
		offset     = 100,
		score      = 1500,
		nrofwaves  = 5 }

#- - - - - - - - - - - - - - - - - - - - -  
var travel:float = 0
var railfollow = []
var enemy1 = []                     # base   enemy set
var enemy2 = []                     # mirror enemy set, only used when mirrorwave is used
var nrEnemiesDestroyed:int = 0
var lastenemyship = Vector2(0,0)    # location last ship killed, used for popup text

#------------------------------------------------------------------------------
func _ready():
	# test if the Global.gd variables/methods exist are valid
	if not get_node_or_null("/root/Global") != null : print("Global.gd missing")
	if not Global.has_method("instance_node")       : print("Global.instance_node() missing")
	if not "center"  in Global                      : print("Global.center missing")
	
	Global.node_enemywave = self
	position = Global.center  # move position of whole scene to 'center of screen'
	fsm = INIT                # State Machine
	
func _exit_tree():
	Global.node_enemywave = null
#------------------------------------------------------------------------------
# void generate_rail( nrofrail:int )
# requires: res_Paths[]
#
func generate_rail( i:int ):                              # (path nr )
	if ( rail is Path2D ):
		if rail.get_child_count() > 0  :
			rail.queue_free()

	if (i < 0) or (i==null) : i = 0 ;
	rail = res_Paths[i].instance()                       # add rail
	self.add_child( rail, true )
	rail.set_rotation( enemywaveconfig.rail_angle )      # give rotation

#------------------------------------------------------------------------------
# void generate_wave(int nrofenemies, bool mirrorwave, int shiptype)
# nrofenemies - nr of enemy ships on a single path
# shiptype    - type of enemy ship to use -> res_Enemy[]
#
func generate_wave( nre:int, st:int ):
	if (nre < 2) or (nre == null) : nre = 2  ;
	if (st <= res_Enemy.size() )  : st = 0   ;
	enemy1.clear()
	enemy2.clear()
	railfollow.clear()
	for nr in range(0, nre ):
		railfollow.append( PathFollow2D.new() )
		rail.add_child( railfollow[nr], true )           # 
		railfollow[nr].set_offset(0)                     # clear offset
		enemy1.append( res_Enemy[st].instance() )
		self.add_child( enemy1[nr], true )
		enemy1[nr].position = railfollow[nr].position
		
	travel = 0
	lastenemyship = Vector2(0,0)

#------------------------------------------------------------------------------
func _process(delta):
	
	if fsm == WAVE:
		nrEnemiesDestroyed = 0
		travel += enemywaveconfig.speed * delta
		
		for nr in range(0, enemy1.size() ):
			
			if not ( enemy1[nr] is Area2D ) :                          # no enemy node in array[nr]
				nrEnemiesDestroyed += 1
			else:
				var i = travel + (nr * -100)                           # enemy[0] is head of enemywave
				if i < 0 : i = 0
				railfollow[nr].set_unit_offset( i / 3000.0 )
				enemy1[nr].position = railfollow[nr].position
				if enemywaveconfig.mirrorwave:
					if nr%2: enemy1[nr].position.x *= -1 ;             # mirror even ships over x-axis
				lastenemyship = railfollow[nr].get_global_position()   # store last enemy pos, used for balloon-text

		if ( nrEnemiesDestroyed == enemywaveconfig.nrEnemies ) :
			fsm = ENEMIESKILLED
			var balloon = res_floatingtext.instance()
			balloon.position = lastenemyship
			balloon.amount = enemywaveconfig.score
			Global.node_creation_parent.add_child(balloon)  # !!! add to 'root' scene ivm coordinates
			Global.add_satoshi(enemywaveconfig.score) #Global.scoreboard.satoshi += enemywaveconfig.score
	
	statemachine()
#------------------------------------------------------------------------------
func statemachine():            #enum {INIT, WAVE, ENEMIESKILLED, NEWWAVEINTRO,ENDOFLEVEL}
	match fsm:
		INIT :
			generate_rail(enemywaveconfig.railnr)
			generate_wave(enemywaveconfig.nrEnemies , enemywaveconfig.shiptype)
			emit_signal("sigEnemyWave","start")
			print("enemywave: sig sending start")
			fsm = WAVE
		#- - - - - - - - - - - - - - - - - - - - -  
		WAVE :
			pass
		#- - - - - - - - - - - - - - - - - - - - - 
		ENEMIESKILLED :
			print("All enemies destroyed, last ship was nr: "+str(lastenemyship))
			enemywaveconfig.railnr    = int( randi() % 3 )
			enemywaveconfig.nrEnemies = int( 2 + 2*randi()%6 )       #even nr
			enemywaveconfig.shiptype  = int( randi() % 3 )
			enemywaveconfig.nrofwaves -= 1
			if enemywaveconfig.nrofwaves <= 0:
				fsm = ENDOFLEVEL
			else:
				fsm = NEWWAVEINTRO
		#- - - - - - - - - - - - - - - - - - - - - 
		NEWWAVEINTRO :
			var balloon = res_floatingtext.instance()
			balloon.position = Vector2(500, 200 )
			balloon.amount = " WAVE " + str(enemywaveconfig.nrofwaves)
			Global.node_creation_parent.add_child(balloon) 
			fsm = INIT
		#- - - - - - - - - - - - - - - - - - - - - 
		ENDOFLEVEL:
			var balloon = res_floatingtext.instance()
			balloon.position = Vector2(500, 700 )
			balloon.amount = "END OF LEVEL"
			balloon.delay = 4
			Global.node_creation_parent.add_child(balloon) 
			emit_signal("sigEnemyWave","end")
			print("enemywave: sig sending end")
			self.queue_free()
		#- - - - - - - - - - - - - - - - - - - - - 

#==============================================================================


	#- - - - - - - - - - - - - - - - - - - - -  var's
#		print( "gettree enemy" + str( enemy[nr].get_node("Hitbox").get_name() )  )
#		if not ( enemy[nr].get_node("Hitbox").connect("area_entered",self ,"_signal_cruiserhit") ):
#			print("Enemies.gd signal->area_entered connect problem ")

#	if not $Path_01_loopcenter/PathFollow2D/BattleCruiser/Hitbox.connect("area_entered",self,"_signal_cruiserhit") :

#------------------------------------------------------------------------------
