# Clase 03 - Tarea

## Objetivo
- Aplicar el patron de persistencia con JPA/Hibernate visto en clase (Entity + Repository + Service) a una entidad nueva del proyecto.
- Practicar la migracion de un modelo que hoy vive en memoria hacia una entidad gestionada por Spring Data JPA.
- Reforzar la separacion entre DTO (clase 02) y entidad de persistencia (clase 03), sin mezclarlas.

## Enunciado
- En la clase 02 se creo `CustomerRequestDto` para validar el alta de un cliente, pero `Customer` todavia vivia en memoria.
- Ahora, siguiendo el mismo patron trabajado en clase con `Product`, convertir `Customer` en una entidad persistida con JPA.
- Crear `Customer` como entidad JPA con:
	- `@Entity`
	- `@Table(name = "customers")`
	- `@Id` + `@GeneratedValue(strategy = GenerationType.IDENTITY)`
	- Columnas para `firstName`, `lastName`, `email` y `phone` (`@Column(nullable = false)` donde corresponda segun las validaciones ya definidas en `CustomerRequestDto`).
- Crear `CustomerRepository extends JpaRepository<Customer, Long>`.
- Ajustar `CustomerService` para que use `CustomerRepository` en lugar de la lista en memoria, manteniendo los metodos ya definidos (listar, buscar por id, crear).
- Las validaciones del DTO (`CustomerRequestDto`) no cambian: siguen resolviendo la calidad del dato de entrada, independientemente de que ahora se persista.
- Usar la misma configuracion de H2 ya definida para `Product` (no hace falta un datasource nuevo).

## Entrega esperada
- Codigo funcional y compilable.
- Endpoints funcionando sobre datos reales (persistidos en H2):
	- `GET /api/customers`
	- `GET /api/customers/{id}`
	- `POST /api/customers`
- Verificar en la consola H2 (`/h2-console`) que la tabla `customers` existe y que los clientes creados por `POST` se reflejan ahi.
- Probar al menos un caso feliz de alta y consulta de un cliente.

## Opcional (para profundizar)
- Agregar clientes de ejemplo en `data.sql` (recordando que, si el esquema lo genera Hibernate, hace falta `spring.jpa.defer-datasource-initialization=true` para que `data.sql` no falle).
- Pensar (sin necesidad de implementarlo todavia): ¿por que podria convenir marcar `email` como unico a nivel de base de datos (`@Column(unique = true)`)? ¿Que pasaria hoy si se cargan dos clientes con el mismo email?

