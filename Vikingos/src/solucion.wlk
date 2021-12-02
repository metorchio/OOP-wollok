class VikingoNoTienePermitidoIrAExpedicionException inherits DomainException {}
class ExpedicionNoValeLaPenaException inherits DomainException {}
class RangoMaximoAlcanzadoException inherits DomainException {}

class Aldea {
	const property cantCrucifijos
	method botin(cantVikingosInvolucrados) = cantCrucifijos
	method valeLaPenaInvadir(cantVikingosInvolucrados) = self.botin(cantVikingosInvolucrados) > 15
}

class AldeaAmurallada inherits Aldea {
	const property cantMinimaDeVikingos
	override method valeLaPenaInvadir(cantVikingosInvolucrados) = 
			super(cantVikingosInvolucrados) && (cantVikingosInvolucrados > cantMinimaDeVikingos) 
}

class Capital {
	const property factorDeRiqueza
	method botin(cantVikingosInvolucrados) = cantVikingosInvolucrados * factorDeRiqueza
	method valeLaPenaInvadir(cantVikingosInvolucrados) = (self.botin(cantVikingosInvolucrados) / cantVikingosInvolucrados) > 3 
}

class Expedicion {
	const property lugaresInvolucrados = []
	const property vikingosInvolucrados = []
	method cantidadDeIntegrantes() = vikingosInvolucrados.size()
	method valeLaPena() = lugaresInvolucrados.all{ lugar => lugar.valeLaPenaInvadir(self.cantidadDeIntegrantes()) }
	method subirVikingo(vikingo) {
		if( not vikingo.tienePermitidoIrAUnaExpedicion() ) throw new VikingoNoTienePermitidoIrAExpedicionException()
		vikingosInvolucrados.add(vikingo)
	}
	method llevarACabo() {
		if( not self.valeLaPena() ) throw new ExpedicionNoValeLaPenaException()
		const botinDeExpedicion = lugaresInvolucrados.forEach{ lugar => lugar.botin(self.cantidadDeIntegrantes()) }.sum()
		const botinParaCadaVikingo = botinDeExpedicion / self.cantidadDeIntegrantes()
		vikingosInvolucrados.forEach{ vikingo => vikingo.recibirBotin(botinParaCadaVikingo) }
	}
}

class Vikingo {
	var property trabajo
	var property rango
	var botin = 0
	method tienePermitidoIrAUnaExpedicion()
	method recibirBotin(botinGanado) { botin += botinGanado }
	method puedeIrAUnaExpedicion() = trabajo.esProductivo() && rango.tienePermitidoIrAUnaExpedicion(trabajo)
	method ascenderSocialmente(){ rango.ascender(self) }
}

class Casta {
	method tienePermitidoIrAUnaExpedicion(trabajo) = true
}

//esclavos
object jarl inherits Casta {
	override method tienePermitidoIrAUnaExpedicion(trabajo) = trabajo.tieneArmas()
	method ascender(vikingo) {
		vikingo.rango( karl )
		vikingo.trabajo().gananciasPorAscendo()
	}  
}

//casta media
object karl inherits Casta {
	method ascender(vikingo) {
		vikingo.rango( thrall)
	}   
}

//nobles
object thrall inherits Casta {
	method ascender(vikingo){ throw new RangoMaximoAlcanzadoException() }   
}

class Granjero {
	var property cantHijos
	var property hectareasDesignadas
	method gananciasPorAscendo(){
		cantHijos += 2
		hectareasDesignadas += 2
	}
	method tieneArmas() = false
	method esProductivo() = (hectareasDesignadas / cantHijos) > 2
}

class Soldado {
	var property vidasCargadas
	var property cantArmas
	method gananciasPorAscendo() {
		cantArmas += 10
	}
	method tieneArmas() = cantArmas > 0
	method esProductivo() = vidasCargadas > 20 && self.tieneArmas() 
}
