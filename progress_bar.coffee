(($)->
  defaults =
    min:0
    max:100
    value:0
    width:600
    height:30
    background:'yellow'
    start:(e)->
    change:(e)->
    end:(e)->

  privates =
    init: (options) ->
      return @each ()->
        opts = $.extend {},defaults,options
        $this = $(@)
        data = $this.data('progressbar')
        unless data
          privates.generate_html($this,opts)
          privates.bind_event($this,opts)

    generate_html: ($this,opts)->
      percent = Math.round((opts.value - opts.min) / (opts.max - opts.min) * 100) + '%'; 
      warper = $this.css({'width':opts.width,'height':opts.height}).addClass('progressbar').data('progressbar',{
        min:opts.min,
        max:opts.max,
        val:opts.value,
        percent:percent,
        started:false
      })
    
      content = $('<div />').css({'height':opts.height,'width':percent,'background':opts.background}).addClass('progressbar-value').appendTo(warper)    
  
    bind_event: ($this,opts) -> 
      $this.bind('start.progressbar':opts.start,'change.progressbar':opts.change,'end.progressbar':opts.end) 


  methods =
    get_min:->
      $(@).data('progressbar').min
        
    get_max:->
      $this = $(@)
      $(@).data('progressbar').max

    get_val:->
      $(@).data('progressbar').val

    get_percent:->
      $(@).data('progressbar').percent

    set_val: (val)->    
      min  = methods.get_min.apply @
      max  = methods.get_max.apply @
      data = $(@).data('progressbar')

      unless data.started
        startEvent = $.extend {},data,{type:'start.progressbar'}
        $(@).trigger(startEvent)
        data.started = true


      if val < min
        val = min
      if val > max
        val = max

      percent = Math.round((val - min) / (max - min) * 100) + '%'; 

      data.val = val

      data.percent = percent



      @.find('.progressbar-value').animate({'width':percent},()=>
        if val == max 
          endEvent = $.extend {},data,{type:'end.progressbar'}
          $(@).parent().trigger(endEvent) 
      )

      @.find('.progressbar-value').animate({'width': percent}, => 
        if val == max
          completeEvent = $.extend {}, data, {type: 'complete.progressbar',percent: percent}
          $(@).parent().trigger(completeEvent)
        
      )
      
      changeEvent = $.extend {},data,{type:'change.progressbar',percent: percent}

      $(@).trigger(changeEvent)

  $.fn.progressbar = (options_or_method) ->
    if methods[options_or_method]
      methods[options_or_method].apply @,Array.prototype.slice.call arguments,1
    else if $.isPlainObject(options_or_method)
      privates['init'].apply @,arguments
    else
      $.error("#{options_or_method} is not defined in progressbar")
)(jQuery)