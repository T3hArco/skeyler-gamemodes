
#include <interface.h>
#include "eiface.h"
#include "engine/ienginetrace.h"
#include "gm_navigation/nav.h"
#include "tier0/memdbgon.h"

// Get nav.cpp to compile
class IEngineTrace;
class IThreadPool;
IEngineTrace *enginetrace = NULL;
IThreadPool *threadPool = NULL;

GMOD_MODULE(Init, Shutdown);

struct Border
{
	Node *head;
	Node *tail;
};

struct BorderData
{
	BorderData():border(NULL), next(NULL), prev(NULL) {}
	Border *border;
	Node *next;
	Node *prev;
};

int VectorMetaRef = NULL;

ILuaObject* NewVectorObject(lua_State* L, const Vector& vec)
{
	if(VectorMetaRef == NULL)
	{
		// @azuisleet Get a reference to the function to survive past 510 calls!
		ILuaObject *VectorMeta = Lua()->GetGlobal("Vector");
			VectorMetaRef = VectorMeta->GetReference();
		//VectorMeta->UnReference();
	}

	Lua()->PushReference(VectorMetaRef);

	if(Lua()->GetType(-1) != GLua::TYPE_FUNCTION)
	{
		//Msg("gm_navigation error: Not a function: %i\n", Lua()->GetType(-1));
		Lua()->Pop();
		Lua()->Push(Lua()->GetGlobal("Vector"));
	}

		Lua()->Push(vec.x);
		Lua()->Push(vec.y);
		Lua()->Push(vec.z);
	Lua()->Call(3, 1);

	return Lua()->GetReturn(0);
}

void LUA_PushVector(lua_State* L, const Vector& vec)
{
	ILuaObject* obj = NewVectorObject(L, vec);
		Lua()->Push(obj);
	obj->UnReference();
}

Vector& LUA_GetVector(lua_State* L, int stackPos)
{
	return *reinterpret_cast<Vector*>(Lua()->GetUserData(stackPos));
}

inline Border* NODE_GetBorder(Node *node)
{
	BorderData* data = static_cast<BorderData*>(node->customData);
	if( data == NULL )
		return NULL;
	if( data->border == NULL )
		return NULL;
	if( data->border->head == node || data->border->tail == node )
		return data->border;
	else
		return NULL;
}

inline void NODE_SetBorder(Node *node, Border *b)
{
	BorderData* data = static_cast<BorderData*>(node->customData);
	data->border = b;
}

inline Node* NODE_GetNext(Node *node)
{
	BorderData* data = static_cast<BorderData*>(node->customData);
	return data->next;
}

inline void NODE_SetNext(Node *node, Node *next)
{
	BorderData* data = static_cast<BorderData*>(node->customData);
	data->next = next;
}

inline Node* NODE_GetPrev(Node *node)
{
	BorderData* data = static_cast<BorderData*>(node->customData);
	return data->prev;
}

inline void NODE_SetPrev(Node *node, Node *prev)
{
	BorderData* data = static_cast<BorderData*>(node->customData);
	data->prev = prev;
}

void AddConnection( lua_State* L, CUtlVector<Border*> &borders, Node *node, NavDirType nextDir, NavDirType prevDir )
{
	
	if( !node ) return;

	if( node->customData == NULL )
		node->customData = (void*)(new BorderData());

	if( NODE_GetBorder(node) ) //We've already made this node's connections
	{
		//node->SetStatus( NULL, (int)5, 200 );
		//Lua()->Error("ASSERT Failed: Node border was not null");
		return;
	}
	
	Node *nodeNext = node->GetConnectedNode(nextDir);
	Node *nodePrev = node->GetConnectedNode(prevDir);
	
	Border *border1 = NULL;
	if( nodeNext )
	{
		if( nodeNext->customData == NULL )
		{
			nodeNext->customData = (void*)(new BorderData());
			border1 = NULL;
		}
		else
		{
			border1 = NODE_GetBorder(nodeNext);
		}
	}

	Border *border2 = NULL;
	if( nodePrev )
	{
		if( nodePrev->customData == NULL )
		{
			nodePrev->customData = (void*)(new BorderData());
			border2 = NULL;
		}
		else
		{
			border2 = NODE_GetBorder(nodePrev);
		}
	}

	if( border1 == NULL && border2 == NULL )
	{
		//create new border;
		Border *border = new Border();
		border->head = node;
		border->tail = node;
		
		NODE_SetBorder( node, border );

		borders.AddToTail( border );
		return;
	}

	if( border1 && border2 ) //merge
	{
		if( border1 != border2 )
		{
			NODE_SetPrev(border1->tail, node);
			NODE_SetNext(node, border1->tail);
			border1->tail = border2->tail;
			NODE_SetNext(border2->head, node);
			NODE_SetPrev(node, border2->head);
			NODE_SetBorder( border2->tail, border1 );
			NODE_SetBorder( border1->tail, border1 );
			borders.FindAndRemove( border2 ); //abitrarily remove border2
			delete border2;
		}
		else
		{
			//loop
			NODE_SetBorder( node, border1 );
			NODE_SetNext(node, border1->tail);
			NODE_SetPrev(border1->tail, node);
			NODE_SetPrev(node, border1->head);
			NODE_SetNext(border1->head, node);
			border1->head = node;
			border1->tail = node;
		}
	} 
	else if( border1 ) //connect 2 next
	{
		NODE_SetPrev(border1->tail, node);
		NODE_SetNext(node, border1->tail);
		border1->tail = node;
		NODE_SetBorder(node, border1);
	}
	else //( border2 ) //connect to prev
	{
		NODE_SetNext(border2->head, node);
		NODE_SetPrev(node, border2->head);
		border2->head = node;
		NODE_SetBorder(node, border2);
	}
}

bool IsTerritory(Node *node, NavDirType dir, int empire)
{
	Node *connected = node->GetConnectedNode(dir);
	if( !connected )
		return true;
	else
		return connected->GetScoreF() == empire;
}

#define CONNECT( _dir1_, _dir2_ ) AddConnection( L, borders, node, _dir1_, _dir2_ )

void MakeConnections( lua_State* L, CUtlVector<Border*> &borders, Node *node )
{
	if( !node ) return;

	static const unsigned char f_no = 0x01;
	static const unsigned char f_ne = 0x02;
	static const unsigned char f_ea = 0x04;
	static const unsigned char f_se = 0x08;
	static const unsigned char f_so = 0x10;
	static const unsigned char f_sw = 0x20;
	static const unsigned char f_we = 0x40;
	static const unsigned char f_nw = 0x80;
	unsigned char borderflags = 0;
	int empire = (int)(node->GetScoreF());
	if( empire <= 0 ) return;

	if( IsTerritory(node, NORTH     , empire) ) borderflags |= f_no;
	if( IsTerritory(node, NORTHEAST , empire) ) borderflags |= f_ne;
	if( IsTerritory(node, EAST      , empire) ) borderflags |= f_ea;
	if( IsTerritory(node, SOUTHEAST , empire) ) borderflags |= f_se;
	if( IsTerritory(node, SOUTH     , empire) ) borderflags |= f_so;
	if( IsTerritory(node, SOUTHWEST , empire) ) borderflags |= f_sw;
	if( IsTerritory(node, WEST      , empire) ) borderflags |= f_we;
	if( IsTerritory(node, NORTHWEST , empire) ) borderflags |= f_nw;
	//flip the bits
	borderflags = ~borderflags;
		
	//NOTE: all connections must be clockwise around the territory
		
	///////////////// 90 deg corners
	if( (borderflags & (f_no | f_ne | f_ea | f_se | f_so | f_we | f_nw)) == (f_se | f_so | f_we | f_nw) )
	{
		CONNECT( EAST, NORTH );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_sw | f_we | f_nw)) == (f_ne | f_ea | f_so | f_sw) )
	{
		CONNECT( NORTH, WEST );
	}
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_sw | f_we | f_nw)) == (f_no | f_ea | f_se | f_nw) )
	{
		CONNECT( WEST, SOUTH );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_se | f_so | f_sw | f_we)) == (f_no | f_ne | f_sw | f_we) )
	{
		CONNECT( SOUTH, EAST );
	}
	/////////////////// bend - bend (STRAIGHT)
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_we | f_nw)) == (f_no | f_ea) )
	{
		CONNECT( NORTHWEST, SOUTHEAST );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_sw | f_we)) == (f_no | f_we) )
	{
		CONNECT( SOUTHWEST, NORTHEAST );
	}
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_we | f_nw)) == (f_so | f_we) )
	{
		CONNECT( SOUTHEAST, NORTHWEST );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_sw | f_we)) == (f_ea | f_so) )
	{
		CONNECT( NORTHEAST, SOUTHWEST );
	}
	/////////////////// bend - bend (CONCAVE)
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_sw | f_we)) == (f_no | f_ea | f_we) )
	{
		CONNECT( SOUTHWEST, SOUTHEAST );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_se | f_so | f_we)) == (f_no | f_so | f_we) )
	{
		CONNECT( SOUTHEAST, NORTHEAST );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_we | f_nw)) == (f_ea | f_so | f_we) )
	{
		CONNECT( NORTHEAST, NORTHWEST );
	}
	else if( (borderflags & (f_no | f_ea | f_so | f_sw | f_we | f_nw)) == (f_no | f_ea | f_so) )
	{
		CONNECT( NORTHWEST, SOUTHWEST );
	}
	/////////////////// straight - straight (STRAIGHT)
	else if( (borderflags & (f_no | f_ne | f_ea | f_se | f_so | f_we)) == (f_ne | f_ea | f_se) )
	{
		CONNECT( NORTH, SOUTH );
	}
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_sw | f_we)) == (f_se | f_so | f_sw) )
	{
		CONNECT( EAST, WEST );
	}
	else if( (borderflags & (f_no | f_we | f_so | f_sw | f_we | f_nw)) == (f_sw | f_we | f_nw) )
	{
		CONNECT( SOUTH, NORTH );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_we | f_nw)) == (f_no | f_ne | f_nw) )
	{
		CONNECT( WEST, EAST );
	}
	//////////////////
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_we | f_nw)) == (f_no | f_ne) )
	{
		CONNECT( NORTHWEST, EAST );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_se | f_so | f_we)) == (f_ne | f_ea) )
	{
		CONNECT( NORTH, SOUTHEAST );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_se | f_so | f_we)) == (f_ea | f_se) )
	{
		CONNECT( NORTHEAST, SOUTH );
	}
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_sw | f_we)) == (f_se | f_so) )
	{
		CONNECT( EAST, SOUTHWEST );
	}
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_sw | f_we)) == (f_so | f_sw) )
	{
		CONNECT( SOUTHEAST, WEST );
	}
	else if( (borderflags & (f_no | f_ea | f_so | f_sw | f_we | f_nw)) == (f_sw | f_we) )
	{
		CONNECT( SOUTH, NORTHWEST );
	}
	else if( (borderflags & (f_no | f_ea | f_so | f_sw | f_we | f_nw)) == (f_we | f_nw) )
	{
		CONNECT( SOUTHWEST, NORTH );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_we | f_nw)) == (f_no | f_nw) )
	{
		CONNECT( WEST, NORTHEAST );
	}
	////////////////////////// straight - bend (CONCAVE)
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_sw | f_we)) == (f_ne | f_ea | f_so) )
	{
		CONNECT( NORTH, SOUTHWEST );
	}
	else if( (borderflags & (f_no | f_ea | f_so | f_sw | f_we | f_nw)) == (f_no | f_ea | f_nw) )
	{
		CONNECT( WEST, SOUTHEAST );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_sw | f_we)) == (f_no | f_sw | f_we) )
	{
		CONNECT( SOUTH, NORTHEAST );
	}
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_we | f_nw)) == (f_se | f_so | f_we) )
	{
		CONNECT( EAST, NORTHWEST );
	}
	////////////////////////// bend - straight (CONCAVE)
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_sw | f_we)) == (f_no | f_ne | f_we) )
	{
		CONNECT( SOUTHWEST, EAST );
	}
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_we | f_nw)) == (f_so | f_we | f_nw) )
	{
		CONNECT( SOUTHEAST, NORTH );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_sw | f_we)) == (f_ea | f_so | f_sw) )
	{
		CONNECT( NORTHEAST, WEST );
	}
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_we | f_nw)) == (f_no | f_ea | f_se) )
	{
		CONNECT( NORTHWEST, SOUTH );
	}
	/////////////////// bend - bend (CONVEX)
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_sw | f_we)) == (f_so) )
	{
		CONNECT( SOUTHEAST, SOUTHWEST );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_se | f_so | f_we)) == (f_ea) )
	{
		CONNECT( NORTHEAST, SOUTHEAST );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_we | f_nw)) == (f_no) )
	{
		CONNECT( NORTHWEST, NORTHEAST );
	}
	else if( (borderflags & (f_no | f_ea | f_so | f_sw | f_we | f_nw)) == (f_we) )
	{
		CONNECT( SOUTHWEST, NORTHWEST );
	}
	/////////////////// bend - straight (TRIANGLE)
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_sw | f_we)) == (f_no | f_ea | f_se | f_we) )
	{
		CONNECT( SOUTHWEST, SOUTH );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_se | f_so | f_we)) == (f_no | f_ne | f_so | f_we) )
	{
		CONNECT( SOUTHEAST, EAST );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_we | f_nw)) == (f_ea | f_so | f_we | f_nw) )
	{
		CONNECT( NORTHEAST, NORTH );
	}
	else if( (borderflags & (f_no | f_ea | f_so | f_sw | f_we | f_nw)) == (f_no | f_ea | f_so | f_sw) )
	{
		CONNECT( NORTHWEST, WEST );
	}
	/////////////////// straight - bend (TRIANGLE)
	else if( (borderflags & (f_no | f_ea | f_se | f_so | f_sw | f_we)) == (f_no | f_ea | f_sw | f_we) )
	{
		CONNECT( SOUTH, SOUTHEAST );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_se | f_so | f_we)) == (f_no | f_se | f_so | f_we) )
	{
		CONNECT( EAST, NORTHEAST );
	}
	else if( (borderflags & (f_no | f_ne | f_ea | f_so | f_we | f_nw)) == (f_ne | f_ea | f_so | f_we) )
	{
		CONNECT( NORTH, NORTHWEST );
	}
	else if( (borderflags & (f_no | f_ea | f_so | f_sw | f_we | f_nw)) == (f_no | f_ea | f_so | f_nw) )
	{
		CONNECT( WEST, SOUTHWEST );
	}
	////////////////// RARE SUPER CASE
	else if( (borderflags & (f_no | f_ea | f_so | f_we )) == (f_no | f_so) )
	{
		node->SetStatus( NULL, 0, 0 );
		MakeConnections( L, borders, node->GetConnectedNode( NORTHEAST ) );
		MakeConnections( L, borders, node->GetConnectedNode( EAST ) );
		MakeConnections( L, borders, node->GetConnectedNode( SOUTHEAST ) );
		MakeConnections( L, borders, node->GetConnectedNode( SOUTHWEST ) );
		MakeConnections( L, borders, node->GetConnectedNode( WEST ) );
		MakeConnections( L, borders, node->GetConnectedNode( NORTHWEST ) );
	}
	else if( (borderflags & (f_no | f_ea | f_so | f_we )) == (f_ea | f_we) )
	{
		node->SetStatus( NULL, 0, 0 );
		MakeConnections( L, borders, node->GetConnectedNode( NORTHEAST ) );
		MakeConnections( L, borders, node->GetConnectedNode( NORTH ) );
		MakeConnections( L, borders, node->GetConnectedNode( SOUTHEAST ) );
		MakeConnections( L, borders, node->GetConnectedNode( SOUTHWEST ) );
		MakeConnections( L, borders, node->GetConnectedNode( SOUTH ) );
		MakeConnections( L, borders, node->GetConnectedNode( NORTHWEST ) );
	}
}

#undef CONNECT

LUA_FUNCTION(Nav_Flood)
{
	Lua()->CheckType(1, NAV_TYPE);
	Lua()->CheckType(2, GLua::TYPE_TABLE);
	
	Nav *nav = LUA_GetNav(L, 1);
	CUtlLuaVector* tableObjects = Lua()->GetObject(2)->GetMembers();
	
	ILuaObject *resultTable = Lua()->GetNewTable();
	resultTable->Push();
	resultTable->UnReference();

	nav->GetLock().Lock();
	nav->Reset();
	CUtlVector<Node*>& nodes = nav->GetNodes();
	for(int i = 0; i < nodes.Count(); i++)
	{
		nodes[i]->SetStatus( NULL, 0, 0 );
	}

	if( tableObjects->Count() == 0 )
	{
		nav->GetLock().Unlock();
		Lua()->DeleteLuaVector(tableObjects);
		return 1;
	}

	for(int i=0; i < tableObjects->Count(); i++)
	{
		LuaKeyValue kv = tableObjects->Element(i);

		ILuaObject *objValue = kv.pValue;

		if(objValue->GetType() != GLua::TYPE_TABLE)
		{
			Lua()->DeleteLuaVector(tableObjects);
			Lua()->Error("Sass:FloodNav pair value is not a table.\n");
			return 1;
		}

		ILuaObject *objNode = objValue->GetMember(1);
		ILuaObject *objEmpireID = objValue->GetMember(2);
		ILuaObject *objScore = objValue->GetMember(3);

		if(objNode->GetType() != NODE_TYPE || objEmpireID->GetType() != GLua::TYPE_NUMBER || objScore->GetType() != GLua::TYPE_NUMBER)
		{
			objNode->UnReference();
			objEmpireID->UnReference();
			objScore->UnReference();
			Lua()->DeleteLuaVector(tableObjects);
			Lua()->Error("Sass:FloodNav table values incorrect, expected (node,number,number).\n");
			return 1;
		}

		Node *pNode = (Node*)objNode->GetUserData();
		int empireID = objEmpireID->GetInt();
		float score = objScore->GetFloat();
		
		if( pNode != NULL )
		{
			nav->AddOpenedNode(pNode);
			pNode->SetStatus( NULL, empireID, score );
		}

		objNode->UnReference();
		objEmpireID->UnReference();
		objScore->UnReference();
	}
	
	Lua()->DeleteLuaVector(tableObjects);

	CUtlVector<Node*> borderNodes;
	CUtlVector<Node*> closedNodes;

	//TODO: Use a linked list for this.
	CUtlVector<Border*> borders;

	const CUtlVector<Node*>& openedNodes = nav->GetOpenedNodes();
	
	while( openedNodes.Count() > 0 )
	{
		Node *current = openedNodes.Head();
		nav->AddClosedNode(current);
		closedNodes.AddToTail(current);
		
		for(int Dir = NORTH; Dir < nav->GetNumDir(); Dir++)
		{
			Node *connection = current->GetConnectedNode((NavDirType)Dir);

			if(connection == NULL)
			{
				continue;
			}

			if(connection->IsClosed())
			{
				continue;
			}
			//else if(!connection->IsOpened())
			//{
			//	connection->SetStatus( NULL, 0.0f, 0.0f );
			//}

			float newScoreG = current->GetScoreG() + nav->EuclideanDistance(current->GetPosition(), connection->GetPosition());
			if( newScoreG <= 135 && ( !connection->IsOpened() || newScoreG < connection->GetScoreG() ) )
			{
				connection->SetStatus( current, current->GetScoreF(), newScoreG );
				nav->AddOpenedNode( connection );
			}
		}
	}
	
	//FIND BORDER NODES, THIS ISN'T IDEAL!
	
	for( int i = 0; i < closedNodes.Count(); i++ )
	{
		Node *current = closedNodes.Element(i);

		for(int Dir = NORTH; Dir < NORTHEAST; Dir++)
		{
			Node *connection = current->GetConnectedNode((NavDirType)Dir);

			if(connection == NULL)
			{
				continue;
			}

			if(connection->GetScoreF() != current->GetScoreF())
			{
				if( !borderNodes.HasElement(current) )
					borderNodes.AddToTail(current);
				break;
			}
		}
	}
	
	for(int i = 0; i < borderNodes.Count(); i++)
	{
		Node *node = borderNodes.Element(i);

		MakeConnections( L, borders, node );
	}
	
	//Build result table for Lua
	int count = 1;
	for( int i = 0; i < borders.Count(); i++ )
	{
		resultTable = Lua()->GetObject(3); //get the result table to survive past 510 calls
		Border *border = borders.Element(i);
		ILuaObject *tbl = Lua()->GetNewTable(); //create a new lua table for this border
		int nodeCount = 1;
		int empireID = 0;
		Node *start = border->tail;
		Node *current = start;
		while( current )
		{
			empireID = current->GetScoreF();

			LUA_PushVector(L, *(current->GetPosition()));
				ILuaObject *obj = Lua()->GetObject();
				tbl->SetMember(nodeCount++, obj);
				obj->UnReference();
			Lua()->Pop();
			
			Node *next = NODE_GetNext(current);
			
			//Clear border info
			if( current->customData )
			{
				BorderData *data = (BorderData*)current->customData;
				data->border = NULL;
				data->next = NULL;
				data->prev = NULL;
			}

			current = next;

			if( current == start )
			{
				LUA_PushVector(L, *(current->GetPosition()));
					ILuaObject *obj = Lua()->GetObject();
					tbl->SetMember(nodeCount++, obj);
					obj->UnReference();
				Lua()->Pop();
				break;
			}
		}

		tbl->SetMember("empireID", (float)empireID);
		resultTable->SetMember((float)(count++), tbl);
		resultTable->UnReference();
		tbl->UnReference();
	}

	borders.PurgeAndDeleteElements();
	borderNodes.Purge();
	closedNodes.Purge();

	nav->GetLock().Unlock();

	return 1;
}

LUA_FUNCTION(Nav_GetTerritory)
{
	Lua()->CheckType(1, NAV_TYPE);
	Lua()->CheckType(2, GLua::TYPE_VECTOR);
	
	Nav *nav = LUA_GetNav(L, 1);
	
	Node *node = nav->GetClosestNode( LUA_GetVector(L, 2) );
	if( !node )
		return 0;
	
	int empireID = node->GetScoreF();

	Lua()->Push(empireID);

	return 1;
}

int Init(lua_State* L)
{
	ILuaObject *navMeta = Lua()->GetMetaTable(NAV_NAME, NAV_TYPE);
	ILuaObject *indexTable = navMeta->GetMember("__index");
	indexTable->SetMember("FloodTerritory", Nav_Flood);
	indexTable->SetMember("GetTerritory", Nav_GetTerritory);
	indexTable->UnReference();
	navMeta->UnReference();

	Msg("gmsv_sassilization: Loaded\n");

	return 0;
}

int Shutdown(lua_State* L)
{
	if(VectorMetaRef)
	{
		Lua()->FreeReference(VectorMetaRef);
		VectorMetaRef = NULL;
	}

	return 0;
}