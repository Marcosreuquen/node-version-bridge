# node-version-bridge

Puente de versiones para Node.js — detecta automáticamente la versión declarada en tu proyecto y la aplica usando tu gestor de versiones preferido.

## Problema

Muchos proyectos Node ya tienen archivos como `.nvmrc` o `.node-version`, pero si usás un gestor de versiones diferente al del equipo (asdf, nvm, fnm, mise, n), terminás manteniendo archivos duplicados o ejecutando comandos manuales cada vez que cambiás de proyecto.

## Solución

`nvb` lee los archivos de versión que ya existen en el proyecto y aplica la versión correcta automáticamente al entrar al directorio, sin importar qué gestor de versiones uses.

## Gestores soportados

- **nvm** — `nvm use <version>`
- **fnm** — `fnm use <version>`
- **mise** — `mise shell node@<version>`
- **asdf** — `export ASDF_NODEJS_VERSION=<version>`
- **n** — `n <version>`

## Archivos de versión detectados

Por defecto, en este orden de prioridad:

1. `.nvmrc`
2. `.node-version`
3. `.tool-versions`

## Instalación

### Opción rápida (recomendada)

```bash
git clone https://github.com/marcosreuquen/node-version-bridge.git
cd node-version-bridge
bash install.sh
```

El script:
1. Copia `nvb` a `~/.local/share/nvb/`
2. Agrega automáticamente el hook a tu `.zshrc` o `.bashrc`

Después reiniciá tu shell o ejecutá `source ~/.zshrc` (o `~/.bashrc`).

### Opción manual

Si preferís controlar la instalación:

```bash
git clone https://github.com/marcosreuquen/node-version-bridge.git
```

Luego agregá el hook a tu shell:

**Zsh** — en `~/.zshrc`:

```bash
source /ruta/a/node-version-bridge/hooks/nvb.zsh
```

**Bash** — en `~/.bashrc`:

```bash
source /ruta/a/node-version-bridge/hooks/nvb.bash
```

### Verificar instalación

```bash
nvb doctor
```

## Desinstalación

### Con el script

Desde el directorio del repositorio:

```bash
bash uninstall.sh
```

Esto elimina los archivos instalados, el hook de tu shell config y el caché.

### Manual

1. Borrá la línea `source ...nvb.zsh` (o `nvb.bash`) de tu `.zshrc`/`.bashrc`
2. Eliminá el directorio de instalación: `rm -rf ~/.local/share/nvb`
3. Opcional — eliminá el caché: `rm -rf ~/.cache/node-version-bridge`

## Uso manual

```bash
# Ver versión resuelta vs activa
nvb current

# Diagnóstico completo
nvb doctor

# Ver ayuda
nvb help
```

## Configuración

Todo se configura con variables de entorno:

| Variable | Descripción | Default |
|---|---|---|
| `NVB_MANAGER` | Forzar un gestor específico | auto-detect |
| `NVB_LOG_LEVEL` | Nivel de log: error, warn, info, debug | `error` |
| `NVB_PRIORITY` | Prioridad de archivos (separado por comas) | `.nvmrc,.node-version,.tool-versions` |
| `NVB_CACHE_DIR` | Directorio de caché | `$XDG_CACHE_HOME/node-version-bridge` |

### Ejemplo: cambiar prioridad

```bash
# Priorizar .tool-versions sobre .nvmrc
export NVB_PRIORITY=".tool-versions,.nvmrc,.node-version"
```

### Ejemplo: forzar gestor

```bash
# Siempre usar fnm aunque nvm esté disponible
export NVB_MANAGER="fnm"
```

## Tests

```bash
bash test/run.sh
```

## Resultado esperado

- Menos fricción diaria al cambiar entre proyectos.
- Cero necesidad de commitear archivos específicos de tu gestor cuando ya existe `.nvmrc`/`.node-version`.
- Funciona con cualquier gestor de versiones popular.

---

## Documentación

- [Concepto del producto](./docs/concept.md)
- [Diseño técnico](./docs/technical-design.md)
- [Roadmap](./docs/roadmap.md)
- [Plan de implementación](./docs/implementation-plan.md)
- [Changelog](./CHANGELOG.md)

## Estado

MVP funcional (v0.1.0) — detección, resolución y aplicación automática con 5 gestores soportados.