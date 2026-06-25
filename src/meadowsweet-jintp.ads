with Servlet.Responses;

package Meadowsweet.Jintp is

   type Jintp_Renderer is new Meadowsweet.Renderer with null record;

   overriding procedure Render_Response
     (This : Jintp_Renderer;
      View : String;
      Model : Meadowsweet.Inspectable_Bean'Class;
      Response : in out Servlet.Responses.Response'Class);

end Meadowsweet.Jintp;
