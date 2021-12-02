class TerrenoNoSoportadoPorCultivoException inherits DomainException {}
class TerrenoAlcanzoLimiteDeCultivosException inherits DomainException {}

class Terreno {
	const property cultivos = []
	const property parcelasDeTierraEnM2
	const property riquezaDelSuelo
	
	method costoMantenimientoXM2()
	method maximoPlantasXM2()
	
	method esRico()
	method esCampoAbierto()
	
	method mediaNutricional() = cultivos.map{ cultivo => cultivo.valorNutricional(self) }.sum() / cultivos.size()
	method valorNeto() = cultivos.map{ cultivo => cultivo.precioDeVenta(self) }.sum() - self.costoMantenimientoXM2()
	method plantarCultivo(cultivo) {
		if( ! cultivo.puedePlantarse(self) ) throw new TerrenoNoSoportadoPorCultivoException()
		if( ! (cultivos.size() < self.maximoPlantasXM2()) ) throw new TerrenoAlcanzoLimiteDeCultivosException()
		cultivos.add(cultivo)
	}
}

class CampoAbierto inherits Terreno {
	
	override method esCampoAbierto() = true
	override method esRico() = riquezaDelSuelo > 100
	override method costoMantenimientoXM2() = 500
	override method maximoPlantasXM2() = 4
}

class Invernadero inherits Terreno {
	const property maximoPlantasXM2
	var property dispositivoElectronico
	override method esCampoAbierto() = false
	
	method instalarDispositivoElectronico(dispositivo){ dispositivoElectronico = dispositivo }
	override method maximoPlantasXM2() = maximoPlantasXM2
	override method costoMantenimientoXM2() = 50000 + dispositivoElectronico.costoMantenimiento()
	
	override method esRico() =
		cultivos.size() < (maximoPlantasXM2/2) 
		|| dispositivoElectronico.enriqueceTerreno()
	
}

object reguladorNutricional {
	method enriqueceTerreno() = true  
	method costoMantenimiento() = 2000
}

class Humidificador {
	var property humedadConfigurada
	method enriqueceTerreno() = humedadConfigurada.beetween(20,40)
	method configurarPorcentajeHumedad(humedad){ humedadConfigurada = humedad }
	method costoMantenimiento() {
		if( humedadConfigurada <= 30 ) {
			return 1000
		} else {
			return 4500
		}
	}
}

object panelesSolares {
	method enriqueceTerreno() = false  
	method costoMantenimiento() = -25000
}

object cultivoPapa {
	const property valNutricional = 1500
	method puedePlantarse(terreno) = true
	method valorNutricional(terreno) {
		if( terreno.esRico() ){ return valNutricional *2 } else { return valNutricional }
	} 
	method precioDeVenta(terreno) = self.valorNutricional(terreno) / 2 
}

object cultivoAlgodon {
	method puedePlantarse(terreno) = terreno.esRico()
	method valorNutricional(terreno) = 0
	method precioDeVenta(terreno) = 500
}

class CultivoArbolFrutal {
	var property diaQueSePlanto
	var property fruta
	method edad() {
		var hoy = new Date()
		return hoy - diaQueSePlanto
	}
	method puedePlantarse(terreno) = terreno.esCampoAbierto()
	method valorNutricional(terreno) = 4000.min( self.edad() * 3 )
	method precioDeVenta(terreno) = fruta.cantidad() * fruta.precio()
}

class CultivoPalmeraTropical inherits CultivoArbolFrutal {
	override method puedePlantarse(terreno) = super(terreno) && terreno.esRico()
	override method precioDeVenta(terreno) = super(terreno) * 5
	override method valorNutricional(terreno) = 7500.min( self.edad() * 2 )
}

class Fruta {
	const property cantidad
	const property precio
}

