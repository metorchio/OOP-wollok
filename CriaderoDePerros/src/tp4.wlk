class Perro {
    const property esHembra = 0.randomUpTo(2).roundUp() > 1
    var property velocidad
    var property fuerza
    var property adulto = false

    method status() = self.fuerza() + self.velocidad()
}


// Definir acá los objetos y clases para modelar a los criaderos y estrategias de cruza
class NoSePudoHacerLaCruzaException inherits DomainException{ }
class PerrosIncompatiblesException  inherits NoSePudoHacerLaCruzaException { 
	const property unPerro; 
	const property otroPerro
}
class PerrosDelMismoSexoException inherits PerrosIncompatiblesException { }
class PerrosNoAdultosException inherits PerrosIncompatiblesException { }
class HembraNoSuperaEnFuerzaAlMachoException inherits PerrosIncompatiblesException { }
class CriaderoFaltoDePerros inherits NoSePudoHacerLaCruzaException { }
class CriaderoSinMachosException inherits CriaderoFaltoDePerros { }
class CriaderoSinHembrasException inherits CriaderoFaltoDePerros { }

class Criadero {
  const perros = []
  method recibirPerro(perro) {
    self.perros().add(perro)
  }
  method perros() = perros
  method cruzar(estrategia) {
  	const hembra = self.seleccionarHembra()
  	const macho = self.seleccionarMacho()
  	
  	const cria = estrategia.aplicar(macho, hembra)
    self.perros().add(cria)
  }
  
  method esHembraAdulta(animal) = animal.esHembra() && animal.adulto()
  method esMachoAdulto(animal) = !animal.esHembra() && animal.adulto()

  method seleccionarHembra()
  method seleccionarMacho()
  
}

class CriaderoResponsable inherits Criadero {
  override method seleccionarHembra() = self.perros().filter{p => self.esHembraAdulta(p) }.max{ p => p.status() }
  override method seleccionarMacho() = self.perros().filter{p => self.esMachoAdulto(p) }.max{ p => p.status() }
}

class CriaderoIrresponsable inherits Criadero {
  override method seleccionarHembra() = self.perros().findOrElse( {p => p.esHembra() }, {throw new CriaderoSinHembrasException()} )
  override method seleccionarMacho() = self.perros().findOrElse( {p => !p.esHembra() }, {throw new CriaderoSinMachosException()} )

  override method cruzar(estrategia) {
      try {
        super(estrategia)
      } catch error: PerrosIncompatiblesException {
        self.perros().remove(error.unPerro())
        self.perros().remove(error.otroPerro())
        self.cruzar(estrategia)
      }
  }
}

class EstrategiaDeCruza {
  method esMacho(perro) = !perro.esHembra()
  method esHembra(perro) = perro.esHembra()
  method validarQueSonDeDistintoSexo(unPerro, otroPerro) {
    if( ! ( (self.esMacho(unPerro) && self.esHembra(otroPerro)) || 
        (self.esHembra(unPerro) && self.esMacho(otroPerro)) ) ) throw new PerrosDelMismoSexoException(unPerro=unPerro, otroPerro=otroPerro)
  }
  method validarQueSonAdultos(unPerro, otroPerro) {
    if( ! (unPerro.adulto() && otroPerro.adulto()) ) throw new PerrosNoAdultosException(unPerro=unPerro, otroPerro=otroPerro)
  }
  method validarCompatibilidad(unPerro, otroPerro) {
    self.validarQueSonDeDistintoSexo(unPerro, otroPerro)
    self.validarQueSonAdultos(unPerro, otroPerro)
  }
  
  method reconocerHembra(unPerro, otroPerro) = if( self.esHembra(unPerro) ) return unPerro else return otroPerro
  method reconocerMacho(unPerro, otroPerro) = if( self.esMacho(unPerro) ) return unPerro else return otroPerro

  method calcularVelocidadDeLaCria(macho, hembra)
  method calcularFuerzaDeLaCria(macho, hembra)
  method tenerCria(fuerza, velocidad) = new Perro(velocidad=velocidad, fuerza=fuerza)
  
  method aplicar(unPerro, otroPerro){
    self.validarCompatibilidad(unPerro, otroPerro)
    const hembra = self.reconocerHembra(unPerro, otroPerro)
    const macho = self.reconocerMacho(unPerro, otroPerro)
    return self.tenerCria(
        self.calcularFuerzaDeLaCria(macho, hembra),
        self.calcularVelocidadDeLaCria(macho, hembra)
    )
  } 
  
}

object cruzaPareja inherits EstrategiaDeCruza {
  override method calcularVelocidadDeLaCria(macho, hembra) = (macho.velocidad() + hembra.velocidad()) / 2 
  override method calcularFuerzaDeLaCria(macho, hembra) = (macho.fuerza() + hembra.fuerza()) / 2
}

object hembraDominante inherits EstrategiaDeCruza {    
  method hembraSuperaEnFuerza(macho, hembra) = hembra.fuerza() > macho.fuerza()
  
  override method validarCompatibilidad(unPerro, otroPerro) {
      super(unPerro, otroPerro)
      const hembra = self.reconocerHembra(unPerro, otroPerro)
      const macho = self.reconocerMacho(unPerro, otroPerro)
      if( !self.hembraSuperaEnFuerza(macho, hembra) ) throw new HembraNoSuperaEnFuerzaAlMachoException(unPerro=unPerro, otroPerro=otroPerro)
  }
  
  override method calcularVelocidadDeLaCria(macho, hembra) = hembra.velocidad() + (macho.velocidad()*0.05) 
  override method calcularFuerzaDeLaCria(macho, hembra) = hembra.fuerza() + (macho.fuerza()*0.05)
  
}


object underdog inherits EstrategiaDeCruza {
  override method calcularVelocidadDeLaCria(macho, hembra) = macho.velocidad().min( hembra.velocidad() ) * 2 
  override method calcularFuerzaDeLaCria(macho, hembra) = macho.fuerza().min( hembra.fuerza() ) * 2
}
///////////////////

// Completar acá los métodos para crear los criaderos en base a tu modelo

object creadorDeCriaderos {
	method crearCriaderoIrresponsable() = new CriaderoIrresponsable()
	method crearCriaderoResponsable() = new CriaderoResponsable() 
}



