package iris.helloworld;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

public class Activator
    implements BundleActivator
{
  @Override
  public void start( final BundleContext context ) throws Exception
  {
    System.out.println( "Hello World: Activator.start" );
  }

  @Override
  public void stop( final BundleContext context ) throws Exception
  {
    System.out.println( "Hello World: Activator.stop" );
  }
}
