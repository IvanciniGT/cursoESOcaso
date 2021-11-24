# Esto viene en la doc de ES
# Desactivar la swap
sudo swapoff -a # En la sesión actual
# Permanentemente
# modificar el fichero /etc/fstab, comentando la linea donde se define el fichero de swap

# Aumentar memoria virtual
sudo sysctl -w vm.max_map_count=262144
# Para hacerlo persisten
# habria que modificar el fichero  /etc/sysctl.conf