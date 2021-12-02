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
	method valeLaPena() = lugaresInvolucrados.all{ lugar => lugar.valeLaPenaInvadir(vikingosInvolucrados.size()) }
	method subirVikingo(vikingo) {
		if( ! vikingo.tienePermitidoIrAUnaExpedicion() ) throw new VikingoNoTienePermitidoIrAExpedicionException()
		vikingosInvolucrados.add(vikingo)
	}
	method llevarACabo() {
		if( ! self.valeLaPena() ) throw new ExpedicionNoValeLaPenaException()
		const botinDeExpedicion = lugaresInvolucrados.forEach{ lugar => lugar.botin(vikingosInvolucrados.size()) }.sum()
		const botinParaCadaVikingo = botinDeExpedicion / vikingosInvolucrados.size() 
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

//esclavos
class Jarl {
	method tienePermitidoIrAUnaExpedicion(trabajo) = trabajo.tieneArmas()
	method ascender(vikingo) {
		vikingo.rango( new Karl() )
		vikingo.trabajo().gananciasPorAscendo()
	}  
}

//casta media
class Karl {
	method tienePermitidoIrAUnaExpedicion(trabajo) = true
	method ascender(vikingo) {
		vikingo.rango( new Thrall() )
	}   
}

//nobles
class Thrall {
	method tienePermitidoIrAUnaExpedicion(trabajo) = true
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
