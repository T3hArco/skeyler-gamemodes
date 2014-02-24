-- Author: Jetboom

AddCSLuaFile()

if _FIXEDEMITTERS_ or not CLIENT then return end
_FIXEDEMITTERS_ = true

local OldParticleEmitter = ParticleEmitter

local function ForwardFunc(from, funcname)
	from[funcname] = function(me, a, b, c, d, e, f)
		if not me.Emitter and me.EmitterVars then
			me.Emitter = OldParticleEmitter(unpack(me.EmitterVars))
		end

		return me.Emitter[funcname](me.Emitter, a, b, c, d, e, f)
	end
end

local wrapper = {}

ForwardFunc(wrapper, "Add")
ForwardFunc(wrapper, "Draw")
ForwardFunc(wrapper, "GetNumActiveParticles")
ForwardFunc(wrapper, "SetBBox")
ForwardFunc(wrapper, "SetNearClip")
ForwardFunc(wrapper, "SetNoDraw")
ForwardFunc(wrapper, "SetParticleCullRadius")
ForwardFunc(wrapper, "SetPos")

function wrapper:Finish()
	if self.Emitter then self.Emitter:Finish() end
	self.Emitter = nil
end

local meta = {}
function meta:__gc()
	if self.Emitter then self.Emitter:Finish() end
	self.Emitter = nil
end

function ParticleEmitter(...)
	local e = {}
	for k, v in pairs(wrapper) do e[k] = v end
	e.EmitterVars = {...}
	e.Emitter = OldParticleEmitter(...)
	setmetatable(e, meta)
	return e
end
