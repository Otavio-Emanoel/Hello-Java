# Coleções e Arrays

## Arrays
```java
int[] nums = {1,2,3};
System.out.println(nums[0]); // 1
```

## List, Set, Map (overview)
```java
import java.util.*;

List<String> lista = new ArrayList<>();
lista.add("A");
lista.add("B");

Set<String> conjunto = new HashSet<>();
conjunto.add("X");
conjunto.add("X"); // duplicatas são ignoradas

Map<String, Integer> mapa = new HashMap<>();
mapa.put("idade", 30);
System.out.println(mapa.get("idade")); // 30
```
