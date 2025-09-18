function post(endpoint, data = {}) {
    fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    }).catch(error => console.error('Error:', error));
}

const app = Vue.createApp({
    data() {
        return {
            visible: false,
            currentStep: 1,
            vehicles: [],
            colors: [],
            paymentMethods: [],
            selectedVehicle: null,
            selectedColor: null,
            selectedPaymentMethod: null,
            showSortOptions: false,
            showColorOptions: false,
            sortOptions: {
                'name': 'Trier par nom',
                'price': 'Trier par prix'
            },
            filters: {
                category: '',
                sortBy: 'name',
                search: ''
            },
            notification: {
                show: false,
                message: '',
                type: 'success',
                icon: 'fas fa-check-circle'
            }
        };
    },
    computed: {
        categories() {
            if (!this.vehicles.length) return [];
            const uniqueCategories = [...new Set(this.vehicles.map(vehicle => vehicle.category))];
            return uniqueCategories.sort();
        },
        
        filteredVehicles() {
            let filtered = [...this.vehicles];
            
            if (this.filters.category) {
                filtered = filtered.filter(vehicle => vehicle.category === this.filters.category);
            }
            
            if (this.filters.search.trim()) {
                const searchTerm = this.filters.search.toLowerCase().trim();
                filtered = filtered.filter(vehicle => 
                    vehicle.name.toLowerCase().includes(searchTerm) || 
                    vehicle.category.toLowerCase().includes(searchTerm)
                );
            }
            
            if (this.filters.sortBy === 'name') {
                filtered.sort((a, b) => a.name.localeCompare(b.name));
            } else if (this.filters.sortBy === 'price') {
                filtered.sort((a, b) => a.price - b.price);
            }
            
            return filtered;
        },
        
        canProceed() {
            switch (this.currentStep) {
                case 1:
                    return this.selectedVehicle !== null;
                case 2:
                    return this.selectedColor !== null;
                case 3:
                    return this.selectedPaymentMethod !== null;
                default:
                    return false;
            }
        }
    },
    methods: {
        openMenu(data) {
            this.vehicles = data.vehicles || [];
            this.colors = data.colors || [];
            this.paymentMethods = data.paymentMethods || [];
            
            this.resetSelections();
            this.visible = true;
        },
        
        closeMenu() {
            this.visible = false;
            post('closeMenu');
        },
        
        resetSelections() {
            this.selectedVehicle = null;
            this.selectedColor = null;
            this.selectedPaymentMethod = null;
            this.currentStep = 1;
            this.filters = {
                category: '',
                sortBy: 'name',
                search: ''
            };
        },
        
        getVehicleImage(imageName) {
            if (!imageName) {
                return 'https://i.imgur.com/1Ag2QNF.png';
            }
            return `assets/images/${imageName}`;
        },
        
        formatPrice(price) {
            return new Intl.NumberFormat('fr-FR', { 
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            }).format(price) + ' $';
        },
        
        getRgbString(rgb) {
            if (!rgb || rgb.length < 3) return 'rgb(255, 255, 255)';
            return `rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})`;
        },
        
        selectVehicle(vehicle) {
            this.selectedVehicle = vehicle;
        },
        
        selectColor(color) {
            this.selectedColor = color;
            this.showColorOptions = false;
        },
        
        toggleColorMenu() {
            this.showColorOptions = !this.showColorOptions;
        },
        
        selectPaymentMethod(method) {
            this.selectedPaymentMethod = method;
        },
        
        getPrice() {
            if (!this.selectedVehicle) return 0;
            return this.selectedVehicle.price;
        },
        
        getPaymentIcon(paymentMethod) {
            switch (paymentMethod) {
                case 'money':
                    return 'fas fa-money-bill-wave';
                case 'bank':
                    return 'fas fa-credit-card';
                default:
                    return 'fas fa-dollar-sign';
            }
        },
        
        toggleSort() {
            this.showSortOptions = !this.showSortOptions;
        },
        
        selectSort(value) {
            this.filters.sortBy = value;
            this.showSortOptions = false;
        },
        
        nextStep() {
            if (this.currentStep < 3) {
                this.currentStep++;
            }
        },
        
        prevStep() {
            if (this.currentStep > 1) {
                this.currentStep--;
            }
        },
        
        showNotification(message, type = 'success') {
            this.notification.message = message;
            this.notification.type = type;
            
            if (type === 'success') {
                this.notification.icon = 'fas fa-check-circle';
            } else if (type === 'error') {
                this.notification.icon = 'fas fa-exclamation-circle';
            } else if (type === 'warning') {
                this.notification.icon = 'fas fa-exclamation-triangle';
            }
            
            this.notification.show = true;
            
            setTimeout(() => {
                this.notification.show = false;
            }, 3000);
        },
        
        rentVehicle() {
            if (this.selectedVehicle && this.selectedColor && this.selectedPaymentMethod) {
                const rentalData = {
                    name: this.selectedVehicle.name,
                    model: this.selectedVehicle.model,
                    price: this.selectedVehicle.price,
                    colorIndex: this.selectedColor.colorIndex,
                    paymentMethod: this.selectedPaymentMethod
                };
                
                post('rentVehicle', rentalData);
                
                this.showNotification(`Location de ${this.selectedVehicle.name} en cours...`, 'success');
                this.visible = false;
            }
        }
    },
    mounted() {
        window.addEventListener('message', (event) => {
            const data = event.data;
            
            if (data.type === 'openRentalUI') {
                this.openMenu(data);
            } else if (data.type === 'closeRentalUI') {
                this.visible = false;
            }
        });
        
        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape' && this.visible) {
                this.closeMenu();
            }
        });
        
        document.addEventListener('click', (event) => {
            if (this.showSortOptions && !event.target.closest('.select-menu')) {
                this.showSortOptions = false;
            }
            if (this.showColorOptions && !event.target.closest('.select-menu')) {
                this.showColorOptions = false;
            }
        });
    }
});

app.mount('#app');