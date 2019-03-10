<?php

namespace AppBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;

class BaseController extends Controller
{
    /**
     * @Route("/", name="homepage")
     */
    public function indexAction(Request $request)
    {
        return $this->redirect('/dashboard');
    }

    /**
     * @Route("/dashboard", name="dashboard")
     */
    public function dashBoard(Request $request)
    {
        return $this->render('pages/home.html.twig');
    }

    /**
     * @Route("/realtime/{robot}", name="realtime_robot")
     */
    public function realTime($robot)
    {
        return $this->render('pages/realtime.html.twig', array('robot' => $robot));
    }

    /**
     * @Route("/map/{location}", name="map")
     */
    public function map($location = "fabrica")
    {
        if ($location == "mundial") {
            return $this->render('pages/map/world.html.twig', array('mapa' => $location));
        } else if ($location == "fabrica") {
            return $this->render('pages/map/company.html.twig', array('mapa' => $location));
        } else {
            return $this->redirect('404');
        }
    }

    /**
     * @Route("/mailbox", name="mailbox")
     */
    public function mailbox(Request $request)
    {
        return $this->render('pages/mailbox.html.twig');
    }

    /**
     * @Route("/profile", name="profile")
     */
    public function profile(Request $request)
    {
        return $this->render('pages/profile.html.twig');
    }
}
