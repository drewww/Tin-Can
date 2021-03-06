Ext.setup({
    tabletStartupScreen: 'tablet_startup.png',
    phoneStartupScreen: 'phone_startup.png',
    icon: 'icon.png',
    glossOnIcon: false,
    onReady : function() {
        Ext.regModel('Contact', {
            fields: ['firstName', 'lastName']
        });
        
        var groupingBase = {
            tpl: '<tpl for="."><div class="contact"><strong>{firstName}</strong> {lastName}</div></tpl>',
            itemSelector: 'div.contact',
            
            singleSelect: true,
            grouped: false,
            indexBar: true,
            
            store: new Ext.data.Store({
                model: 'Contact',
                sorters: 'firstName',
                
                getGroupString : function(record) {
                    return record.get('firstName')[0];
                },
                
                data: [
                    {firstName: 'Tommy', lastName: 'Maintz'},
                    {firstName: 'Aaron', lastName: 'Conran'}, 
                    {firstName: 'Ape', lastName: 'Evilias'},
                    {firstName: 'Dave', lastName: 'Kaneda'},
                    {firstName: 'Michael', lastName: 'Mullany'},
                    {firstName: 'Abraham', lastName: 'Elias'},
                    {firstName: 'Jay', lastName: 'Robinson'},
                    {firstName: 'Tommy', lastName: 'Maintz'}, 
                    {firstName: 'Ed', lastName: 'Spencer'},
                    {firstName: 'Jamie', lastName: 'Avins'},
                    {firstName: 'Aaron', lastName: 'Conran'}, 
                    {firstName: 'Dave', lastName: 'Kaneda'},
                    {firstName: 'Michael', lastName: 'Mullany'},
                    {firstName: 'Abraham', lastName: 'Elias'},
                    {firstName: 'Jay', lastName: 'Robinson'},
                    {firstName: 'Tommy', lastName: 'Maintz'}, 
                    {firstName: 'Ed', lastName: 'Spencer'},
                    {firstName: 'Jamie', lastName: 'Avins'},
                    {firstName: 'Aaron', lastName: 'Conran'}, 
                    {firstName: 'Dave', lastName: 'Kaneda'},
                    {firstName: 'Michael', lastName: 'Mullany'},
                    {firstName: 'Abraham', lastName: 'Elias'},
                    {firstName: 'Jay', lastName: 'Robinson'},
                    {firstName: 'Tommy', lastName: 'Maintz'}, 
                    {firstName: 'Ed', lastName: 'Spencer'},        
                ]
            })
        };
        
        if (!Ext.platform.isPhone) {
            new Ext.List(Ext.apply(groupingBase, {
                floating: true,
                width: 350,
                height: 350,
                centered: true,
                modal: true,
                hideOnMaskTap: false
            })).show();
        } 
        else {
            new Ext.List(Ext.apply(groupingBase, {
                fullscreen: true
            }));
        }
    }
});