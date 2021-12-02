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
		|| dispositivoElectronico.esReguladorNutricional()
		|| ( dispositivoElectronico.esHumidificador() && dispositivoElectronico.humedadConfigurada().beetween(20,40) )
	
}

class ReguladorNutricional {
	method esReguladorNutricional() = true
	method esHumidificador() = false
	method esPanelSolar() = false
	method costoMantenimiento() = 2000
}

class Humidificador {
	var property humedadConfigurada
	method esReguladorNutricional() = false
	method esHumidificador() = true
	method esPanelSolar() = false
	method configurarPorcentajeHumedad(humedad){ humedadConfigurada = humedad }
	method costoMantenimiento() {
		if( humedadConfigurada <= 30 ) {
			return 1000
		} else {
			return 4500
		}
	}
}

class PanelesSolares {
	method esReguladorNutricional() = false
	method esHumidificador() = false
	method esPanelSolar() = true
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
	method edad() {
		var hoy = new Date()
		return hoy - diaQueSePlanto
	}
	method puedePlantarse(terreno) = terreno.esCampoAbierto()
	method valorNutricional(terreno) = 4000.max( self.edad() * 3 )
	method cantidadDeFrutaDada() = 0 //De donde sale este dato????
	method precioDeVenta(terreno) = self.cantidadDeFrutaDada()	
}

class CultivoPalmeraTropical inherits CultivoArbolFrutal {
	override method puedePlantarse(terreno) = super(terreno) && terreno.esRico()
	override method precioDeVenta(terreno) = super(terreno) * 5
	override method valorNutricional(terreno) = 7500.max( self.edad() * 2 )
}


