# Clase 04 - Tarea

## Objetivo
- Aplicar el patron de relacion bidireccional visto en clase (`Cart.addItem()` + `@OneToMany`/`@ManyToOne`) a un caso de uso nuevo: agregar un producto existente a un carrito existente.
- Practicar la decision de que informacion va en el DTO de entrada y que informacion se resuelve en el service contra entidades ya persistidas (`Cart`, `Product`).
- Reforzar que agregar un item a la relacion bidireccional implica pasar siempre por el metodo `addItem()` de `Cart`, no manipular la lista `items` directamente.

## Enunciado
- En la actividad se creo un carrito vacio (`POST /api/carts`) y se pudo consultar (`GET /api/carts/{id}`), pero todavia no hay forma de agregarle productos.
- Crear el endpoint `POST /api/carts/{cartId}/items` que reciba un DTO de entrada `AddCartItemRequestDto` con:
  - `productId` (`Long`, obligatorio).
  - `quantity` (`Integer`, obligatorio, debe ser mayor a cero - reutilizar `@Valid` y Bean Validation de la clase 02).
- En `CartService`, agregar un metodo que:
  1. Busque el `Cart` por `cartId` (si no existe, devolver 404 simple, sin `@ControllerAdvice` todavia - eso es clase 05).
  2. Busque el `Product` por `productId` (si no existe, devolver 404 simple).
  3. Cree un `CartItem` con la `quantity` recibida y lo asocie usando `cart.addItem(item)` (el mismo metodo helper visto en clase, para mantener sincronizados ambos lados de la relacion).
  4. Guarde el carrito con `cartRepository.save(cart)` (aprovechando el `cascade = CascadeType.ALL` ya configurado: no hace falta guardar el `CartItem` por separado).
- Devolver el `CartResponseDto` actualizado, mostrando el nuevo item en la lista `items`.

## Entrega esperada
- Codigo funcional y compilable.
- `POST /api/carts/{cartId}/items` funcionando sobre datos reales en H2.
- Caso feliz probado: crear un carrito, agregar un producto existente, consultar el carrito (`GET /api/carts/{id}`) y ver el item reflejado con los datos del producto y la cantidad cargada.
- Caso de error simple probado: intentar agregar un `productId` inexistente (respuesta 404, sin necesidad de formato de error elaborado todavia).

## Opcional (para profundizar)
- Pensar (sin necesidad de implementarlo todavia): si se agrega dos veces el mismo producto al mismo carrito, ¿conviene sumar la cantidad al `CartItem` existente o crear una fila nueva? ¿Como se podria aprovechar `cart.getItems()` (ya cargado por ser una relacion bidireccional) para resolver esta pregunta sin agregar un repository nuevo?
