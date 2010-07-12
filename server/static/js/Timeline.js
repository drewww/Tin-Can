function Timeline(canvas){
   this.canvas=canvas;
   this.eventChanges=[];
   this.tempevents = [[9],[9,12],[9,12,23],[9,12,23,54],[9,12,23,54],[9,12,23,54,68],[9,12,23,54,68,91],[9,12,23,54,68,91,105],[9,12,23,54,68,91,105],[9,12,23,54,68,91,105,133]];
   this.temptime = [11,17,44,61,67,80,93,127,131,136];
   this.n=0;
}

Timeline.prototype={
    currentTime:0,
    colors:["red","orange","yellow","green","blue","purple","brown"],
    start: function(){
        ctx=this.canvas.getContext("2d");
        ctx.clearRect(0,0,300,15);
        ctx.fillStyle="white";
        ctx.fillRect(1,3,298,9);
        ctx.fillStyle="black";
        ctx.fillRect(0,2,1,11);
        ctx.fillRect(299,2,1,11);
        ctx.fillRect(0,2,300,1);
        ctx.fillRect(0,12,300,1);
    },
    draw: function(){
        ctx=this.canvas.getContext("2d");
        this.update(ctx);
        hours = Math.ceil(this.currentTime/60.0);
        hourWidth=300/hours;
        last=0;
        for (var change in this.eventChanges){
            
            index = change%7;
            ctx.fillStyle=this.colors[index];
            if (change!=0){
                length=298.0/60/hours*(this.eventChanges[change]-this.eventChanges[change-1]);
            }
            else{
                length=298.0/60/hours*this.eventChanges[change];
            }
            ctx.fillRect(last+1,3,length,9);
            last=last+length;
        }
        
        index = (this.eventChanges.length)%7;
        length=298.0/60/hours*this.currentTime;
        ctx.fillStyle=this.colors[index];
        ctx.fillRect(last+1,3,length-last,9);
        
        nogood=[]
        for (var x=1;x<hours;x++){
            ctx.fillStyle="black";
            ctx.fillRect(x*hourWidth-2,3,1,9);
            ctx.fillRect(x*hourWidth+2,3,1,9);
            ctx.clearRect(x*hourWidth-1,3,3,1);
            ctx.clearRect(x*hourWidth-1,12,3,1);
        //    ctx.fillStyle="white";
            ctx.clearRect(x*hourWidth-1,2,3,10);
            nogood.push(x*hourWidth-1,x*hourWidth,x*hourWidth+1);
        }
        
        ctx.fillStyle="black";
        while ($.inArray(Math.round(length-1),nogood)>=0){
            length=length+1;
        }
        ctx.fillRect(length-1,0,2,15);
    },
    update: function(ctx){
       /* timeElapsed=Math.round(Math.random()*30);
        this.eventChanges.push(this.currentTime+Math.round(Math.random()*timeElapsed));*/
        this.eventChanges=this.tempevents[this.n];
        this.currentTime=this.temptime[this.n];
        this.n=this.n+1;
        ctx.clearRect(0,0,300,15);
        ctx.fillStyle="white";
        ctx.fillRect(1,3,298,9);
        ctx.fillStyle="black";
        ctx.fillRect(0,2,1,11);
        ctx.fillRect(299,2,1,11);
        ctx.fillRect(0,2,300,1);
        ctx.fillRect(0,12,300,1);
    }
};
