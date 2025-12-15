ratios_vector_speed = [3.5, 2.0, 1.3, 1.0, 0.8]  
ratios_vector_efficiency = [0.96, 0.97, 0.97, 0.97, 0.97]
gearbox_avaiable_speeds=[1,2,3,4,5]

class Gearbox:
    def __init__(self):
        self.ratio
        self.eta
        self.omega_out
        self.tau_out
        self.gear


    def ratio_gearbox (self, gear_input): #considering gear is int [1,2,3,4,5]
        for i in range (gearbox_avaiable_speeds):
            if gear_input==i:
                self.ratio=ratios_vector_speed[self.gear-1]
                self.gear=gear_input
                self.eta=ratios_vector_efficiency[self.gear-1]
            else:
                print("Error: gearbox input not in [1,2,3,4,5]")
                exit()
                
    def output(self,flange_in):
        self.omega_out=flange_in.omega_in/self.ratio
        self.tau_out=flange_in.tau_in*self.ratio*self.efficiency
