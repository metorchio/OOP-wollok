class NingunIntegranteCuentaConLaHabilidadRequeridaException inherits DomainException {}
class EmpleadoNoTienenHabilidadesRequeridasException inherits DomainException {}
class EmpleadoMuertoException inherits DomainException {}

class Empleado {
	var property salud
	var property puesto
	const property habilidades = #{}
	method estaIncapacitado() = salud < puesto.saludCritica()
	method puedeUsarHabilidad(habilidad) {
		return not puesto.estaIncapacitado(salud) 
				&& habilidades.contains(habilidad)
	}
	method aprenderHabilidad(habilidad) = habilidades.add(habilidad)
	
	method chequearHabilidadesRequeridas(mision) {
		const cumpleConLasHabilidadesRequetidas = mision.habilidadesRequeridas()
				.all{ habilidadRequerida => self.puedeUsarHabilidad(habilidadRequerida) }
		if( !cumpleConLasHabilidadesRequetidas ) throw new EmpleadoNoTienenHabilidadesRequeridasException() 
	}
	method recibirDanio(danio){ 
		if( danio < salud ) {
			salud = (salud - danio)
		} else {
			throw new EmpleadoMuertoException()
		}
	}
		
	method cumplirMision(mision) {
		self.chequearHabilidadesRequeridas(mision)
		self.recibirDanio(mision.peligrosidad())
		puesto.misionCompletada(mision, self)
	}
	
}


class Jefe inherits Empleado {
	const property subordinados = #{}
	override method puedeUsarHabilidad(habilidad) {
		return super(habilidad)
		|| subordinados.any{ subordinado => subordinado.puedeUsarHabilidad(habilidad) }
	}
	method agregarSubordinado(subordinado) = subordinados.add(subordinado)
}

object espia {
	method saludCritica() = 15
	method misionCompletada(mision, empleado) {
		mision.habilidadesRequeridas()
				.forEach{ habilidad => empleado.aprenderHabilidad(habilidad) }
	}
}

class Oficinista {
	var property estrellasGanadas = 0
	method saludCritica() = 40 - (5 * estrellasGanadas)
	method ganarEstrella(){
		estrellasGanadas = estrellasGanadas+1
	}
	method misionCompletada(mision, empleado) {
		estrellasGanadas = estrellasGanadas + 1
		if( estrellasGanadas == 3 ) empleado.puesto(espia)
	}
}

class Equipo {
	const property integrantes = #{}
	method agregarIntegrante(empleado) = integrantes.add(empleado)
	method chequearHabilidadesRequeridas(mision) {
		mision.habilidadesRequeridas().all{ habilidadRequerida => 
			integrantes.findOrElse({ integrante => integrante.puedeUsarHabilidad(habilidadRequerida) },
				throw new NingunIntegranteCuentaConLaHabilidadRequeridaException()
			)}
	} 
	method recibirDanio(danio){
	 	integrantes.forEach{ empleado => empleado.recibirDanio(danio/3) }
	}	
	method completarMision(mision){
		integrantes.forEach{empleado => empleado.completarMision(mision) }
	}		
	
	method cumplirMision(mision) {
		self.chequearHabilidadesRequeridas(mision)
		self.recibirDanio(mision.peligrosidad())
		self.completarMision(mision)
	}
}

class Mision {
	const property nombreSecreto
	const property habilidadesRequeridas = #{}
	const property peligrosidad
	method habilidadesRequeridas(habilidades) = habilidadesRequeridas.addAll(habilidades)
	method realizarMision(aCargo) {
		aCargo.cumplirMision()
		aCargo.recibirDanio(peligrosidad)
		aCargo.completarMision(self)
	}
}



