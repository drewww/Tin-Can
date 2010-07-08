function Timeline(canvas){
   this.canvas=canvas;
   this.eventChanges=[];
}

Timeline.prototype={
    n:0,
    currentTime:0,
    colors:["red","orange","yellow","green","blue","purple","brown"],
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
            ctx.fillRect(last+1,1,length,13);
            last=last+length;
        }
        for (var x=1;x<hours;x++){
            ctx.fillStyle="black";
            ctx.fillRect(x*hourWidth-2,0,1,15);
            ctx.fillRect(x*hourWidth+2,0,1,15);
            ctx.fillStyle="white";
            ctx.fillRect(x*hourWidth-1,0,3,1);
            ctx.fillRect(x*hourWidth-1,14,3,1);
        }
    },
    update: function(ctx){
        this.n=this.n+10;
        this.eventChanges.push(this.n);
        this.currentTime=this.currentTime+15;
        console.log(this.eventChanges);
        console.log(this.currentTime);
        ctx.fillStyle="white";
        ctx.clearRect(0,0,300,15);
        ctx.fillRect(1,1,298,13);
        ctx.fillStyle="black";
        ctx.strokeRect(0,0,300,15);
    }
};
